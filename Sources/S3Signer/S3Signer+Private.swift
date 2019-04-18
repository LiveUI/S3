import Foundation
import HTTP
import Crypto



/// Private interface
extension S3Signer {
    
	func canonicalHeadersV2(_ headers: [String: String]) -> String {
		let unfoldedHeaders = headers
			.filter { $0.key.lowercased().hasPrefix("x-amz") }
			.mapValues {
				// unfold values as per RFC 2616 section 4.2
				$0.split(separator: "\n")
					.map { $0.trimmingCharacters(in: .whitespaces) }
					.joined(separator: " ")
			}
		let groupedHeaders = Dictionary<String, String>(unfoldedHeaders.map { ($0.key.lowercased(), $0.value) },
														uniquingKeysWith: { "\($0),\($1)" })
		return Array(groupedHeaders.keys)
			.sorted(by: { $0.localizedCompare($1) == ComparisonResult.orderedAscending })
			.map {
				let trimmedHeader = $0.trimmingCharacters(in: .whitespaces)
				return "\(trimmedHeader):\(groupedHeaders[$0]!)"
			}
			.joined(separator: "\n")
	}

    func canonicalHeaders(_ headers: [String: String]) -> String {
        let headerList = Array(headers.keys)
            .map { "\($0.lowercased()):\(headers[$0]!)" }
            .filter { $0 != "authorization" }
            .sorted(by: { $0.localizedCompare($1) == ComparisonResult.orderedAscending })
            .joined(separator: "\n")
            .appending("\n")
        return headerList
    }
    
    func createCanonicalRequest(_ httpMethod: HTTPMethod, url: URL, headers: [String: String], bodyDigest: String) throws -> String {
        let query = try self.query(url) ?? ""
        return [
            httpMethod.description,
            path(url),
            query,
            canonicalHeaders(headers),
            signed(headers: headers),
            bodyDigest
        ].joined(separator: "\n")
    }
    
    func createSignature(_ stringToSign: String, timeStampShort: String, region: Region) throws -> String {
        let dateKey = try HMAC.SHA256.authenticate(timeStampShort.convertToData(), key: "AWS4\(config.secretKey)".convertToData())
        let dateRegionKey = try HMAC.SHA256.authenticate(region.name.description.convertToData(), key: dateKey)
        let dateRegionServiceKey = try HMAC.SHA256.authenticate(config.service.convertToData(), key: dateRegionKey)
        let signingKey = try HMAC.SHA256.authenticate("aws4_request".convertToData(), key: dateRegionServiceKey)
        let signature = try HMAC.SHA256.authenticate(stringToSign.convertToData(), key: signingKey)
        return signature.hexEncodedString()
    }
    
    func createStringToSign(_ canonicalRequest: String, dates: Dates, region: Region) throws -> String {
        let canonRequestHash = try SHA256.hash(canonicalRequest.convertToData()).hexEncodedString()
        return ["AWS4-HMAC-SHA256", dates.long, credentialScope(dates.short, region: region), canonRequestHash].joined(separator: "\n")
    }
    
    func credentialScope(_ timeStampShort: String, region: Region) -> String {
        let arr = [timeStampShort, region.name.description, config.service, "aws4_request"]
        return arr.joined(separator: "/")
    }
    
	static fileprivate let canonicalSubresources = ["acl", "lifecycle", "location", "logging", "notification",
													"partNumber", "policy", "requestPayment", "torrent",
													"uploadId", "uploads", "versionId", "versioning", "versions", "website"]
	static fileprivate let canonicalOverridingQueryItems = ["response-content-type", "response-content-language", "response-expires",
															"response-cache-control", "response-content-disposition", "response-content-encoding"]

	fileprivate func canonicalResourceV2(url: URL, region: Region, bucket: String?) -> String {
		// unless there is a custom hostname, S3URLBuilder uses virtual hosting (bucket name is in host name part)
		var canonical = ""
		let bucketString = bucket ?? ""
		if region.hostName == nil, !bucketString.isEmpty {
			canonical = "/\(bucketString)"
		}
		let path = url.path
		canonical += path.isEmpty ? "/" : path

		if let bucket = bucket, !bucket.isEmpty, url.path.isEmpty || url.path == "/" {
			return "/\(bucket)".finished(with: "/")
		}
		if url.path.isEmpty {
			return "/"
		}
		if let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
		   let queryItems = components.queryItems {
			let relevantItems: [String] = queryItems
				.filter {
					let name = $0.name.lowercased()
					return S3Signer.canonicalSubresources.contains(name) || S3Signer.canonicalOverridingQueryItems.contains(name)
				}
				.sorted {
					let result = $0.name.caseInsensitiveCompare($1.name)
					return result == .orderedAscending
				}
				.map {
					if let value = $0.value {
						return "\($0.name)=\(value)"
					}
					return $0.name
				}
			if !relevantItems.isEmpty {
				canonical += relevantItems.joined(separator: "&")
			}
		}
		return url.path.encode(type: .pathAllowed) ?? "/"
	}

	func generateAuthHeaderV2(_ httpMethod: HTTPMethod, url: URL, headers: [String: String], dates: Dates, region: Region, bucket: String?) throws -> String {
		let method = httpMethod.description
		let contentMD5 = headers["content-MD5"] ?? ""
		let contentType = headers["content-type"] ?? ""
		let date = headers["Date"] ?? headers["Date"] ?? ""
		let canonicalizedAmzHeaders = canonicalHeadersV2(headers)
		let canonicalizedResource = canonicalResourceV2(url: url, region: region, bucket: bucket)
		let stringToSign = "\(method)\n\(contentMD5)\n\(contentType)\n\(date)\n\(canonicalizedAmzHeaders)\n\(canonicalizedResource)"
		let signature = try HMAC.SHA1.authenticate(stringToSign.convertToData(), key: config.secretKey.convertToData()).base64EncodedString()
		let authHeader = "AWS \(config.accessKey):\(signature)"
		return authHeader
	}

    func generateAuthHeader(_ httpMethod: HTTPMethod, url: URL, headers: [String: String], bodyDigest: String, dates: Dates, region: Region) throws -> String {
        let canonicalRequestHex = try createCanonicalRequest(httpMethod, url: url, headers: headers, bodyDigest: bodyDigest)
        let stringToSign = try createStringToSign(canonicalRequestHex, dates: dates, region: region)
        let signature = try createSignature(stringToSign, timeStampShort: dates.short, region: region)
        let authHeader = "AWS4-HMAC-SHA256 Credential=\(config.accessKey)/\(credentialScope(dates.short, region: region)), SignedHeaders=\(signed(headers: headers)), Signature=\(signature)"
        return authHeader
    }
    
	func getDates(_ date: Date) -> Dates {
		return Dates(date)
    }
    
    func path(_ url: URL) -> String {
        return !url.path.isEmpty ? url.path.encode(type: .pathAllowed) ?? "/" : "/"
    }
    
    func presignedURLCanonRequest(_ httpMethod: HTTPMethod, dates: Dates, expiration: Expiration, url: URL, region: Region, headers: [String: String]) throws -> (String, URL) {
        guard let credScope = credentialScope(dates.short, region: region).encode(type: .queryAllowed),
            let signHeaders = signed(headers: headers).encode(type: .queryAllowed) else {
                throw Error.invalidEncoding
        }
        let fullURL = "\(url.absoluteString)?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=\(config.accessKey)%2F\(credScope)&X-Amz-Date=\(dates.long)&X-Amz-Expires=\(expiration.value)&X-Amz-SignedHeaders=\(signHeaders)"

        // This should never throw.
        guard let url = URL(string: fullURL) else {
            throw Error.badURL(fullURL)
        }
        
        let query = try self.query(url) ?? ""
        return (
            [
                httpMethod.description,
                path(url),
                query,
                canonicalHeaders(headers),
                signed(headers: headers),
                "UNSIGNED-PAYLOAD"
                ].joined(separator: "\n"),
            url
        )
    }
    
    func query(_ url: URL) throws -> String? {
        if let queryItems = URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems {
            let items = queryItems.map({ ($0.name.encode(type: .queryAllowed) ?? "", $0.value?.encode(type: .queryAllowed) ?? "") })
            let encodedItems = items.map({ "\($0.0)=\($0.1)" })
            return encodedItems.sorted().joined(separator: "&")
        }
        return nil
    }
    
    func signed(headers: [String: String]) -> String {
        return Array(headers.keys).map { $0.lowercased() }.filter { $0 != "authorization" }.sorted().joined(separator: ";")
    }
    
    func update(headers: [String: String], url: URL, longDate: String, bodyDigest: String, region: Region?) -> [String: String] {
        var updatedHeaders = headers
        updatedHeaders["x-amz-date"] = longDate
        if (updatedHeaders["host"] ?? updatedHeaders["host"]) == nil {
            updatedHeaders["host"] = (url.host ?? (region ?? config.region).host)
        }
		if config.authVersion == .v4 && bodyDigest != "UNSIGNED-PAYLOAD" && config.service == "s3" {
            updatedHeaders["x-amz-content-sha256"] = bodyDigest
        }
        // According to http://docs.aws.amazon.com/IAM/latest/UserGuide/id_credentials_temp_use-resources.html#RequestWithSTS
        if let token = config.securityToken {
            updatedHeaders["x-amz-security-token"] = token
        }
        return updatedHeaders
    }

    func presignedURL(for httpMethod: HTTPMethod, url: URL, expiration: Expiration, region: Region? = nil, headers: [String: String] = [:], dates: Dates) throws -> URL? {
		guard config.authVersion == .v4 else {
			throw Error.featureNotAvailableWithV2Signing
		}

		var updatedHeaders = headers

        let region = region ?? config.region

        updatedHeaders["host"] = url.host ?? region.host

        let (canonRequest, fullURL) = try presignedURLCanonRequest(httpMethod, dates: dates, expiration: expiration, url: url, region: region, headers: updatedHeaders)

        let stringToSign = try createStringToSign(canonRequest, dates: dates, region: region)
        let signature = try createSignature(stringToSign, timeStampShort: dates.short, region: region)
        let presignedURL = URL(string: fullURL.absoluteString.appending("&X-Amz-Signature=\(signature)"))
        return presignedURL
    }

    func headers(for httpMethod: HTTPMethod, urlString: URLRepresentable, region: Region? = nil, bucket: String? = nil, headers: [String: String] = [:], payload: Payload, dates: Dates) throws -> HTTPHeaders {
        guard let url = urlString.convertToURL() else {
            throw Error.badURL("\(urlString)")
        }

		let bodyDigest = (config.authVersion == .v4) ? try payload.hashed() : ""
        let region = region ?? config.region
        var updatedHeaders = update(headers: headers, url: url, longDate: dates.long, bodyDigest: bodyDigest, region: region)

        if httpMethod == .PUT && payload.isBytes {
            updatedHeaders["content-md5"] = try MD5.hash(payload.bytes).base64EncodedString()
        }

        if httpMethod == .PUT || httpMethod == .DELETE {
            updatedHeaders["content-length"] = payload.size()
            if httpMethod == .PUT && url.pathExtension != "" {
                updatedHeaders["content-type"] = (MediaType.fileExtension(url.pathExtension) ?? .plainText).description
            }
        }

		switch config.authVersion {
			case .v2:
				updatedHeaders["authorization"] = try generateAuthHeaderV2(httpMethod, url: url, headers: updatedHeaders, dates: dates, region: region, bucket: bucket)
			case .v4:
				updatedHeaders["authorization"] = try generateAuthHeader(httpMethod, url: url, headers: updatedHeaders, bodyDigest: bodyDigest, dates: dates, region: region)
		}

        var headers = HTTPHeaders()
        for (key, value) in updatedHeaders {
            headers.add(name: key, value: value)
        }

        return headers
    }
}
