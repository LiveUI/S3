import Foundation
import HTTP
import Crypto



/// Private interface
extension S3Signer {
    
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
        return [
            httpMethod.string,
            formattedPath(url.path),
            formattedQueryString(url),
            canonicalHeaders(headers),
            signed(headers: headers),
            bodyDigest
        ].joined(separator: "\n")
    }
    
    func createSignature(_ stringToSign: String, timeStampShort: String, region: Region) throws -> String {
        let dateKey = try HMAC.SHA256.authenticate(timeStampShort.convertToData(), key: "AWS4\(config.secretKey)".convertToData())
        let dateRegionKey = try HMAC.SHA256.authenticate(region.name.rawValue.convertToData(), key: dateKey)
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
        var arr = [timeStampShort, region.name.rawValue, config.service, "aws4_request"]
        if region.name == .none {
            arr.remove(at: 1)
        }
        return arr.joined(separator: "/")
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

    func formattedPath(_ path: String) -> String {
        return !path.isEmpty ? path.encode(type: .pathAllowed) ?? "/" : "/"
    }

    func formattedQueryString(_ url: URL) -> String {
        if let queryItems = URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems {
            return formattedQueryItems(queryItems)
        }
        return ""
    }

    func formattedQueryItems(_ queryItems: [URLQueryItem]) -> String {
        let items = queryItems.map({ ($0.name.encode(type: .queryAllowed) ?? "", $0.value?.encode(type: .queryAllowed) ?? "") })
        let encodedItems = items.map({ "\($0.0)=\($0.1)" })
        return encodedItems.sorted().joined(separator: "&")
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
        if bodyDigest != "UNSIGNED-PAYLOAD" && config.service == "s3" {
            updatedHeaders["x-amz-content-sha256"] = bodyDigest
        }
        // According to http://docs.aws.amazon.com/IAM/latest/UserGuide/id_credentials_temp_use-resources.html#RequestWithSTS
        if let token = config.securityToken {
            updatedHeaders["x-amz-security-token"] = token
        }
        return updatedHeaders
    }

    func headers(for httpMethod: HTTPMethod, urlString: URLRepresentable, region: Region? = nil, headers: [String: String] = [:], payload: Payload, dates: Dates) throws -> HTTPHeaders {
        guard let url = urlString.convertToURL() else {
            throw Error.badURL("\(urlString)")
        }

        let bodyDigest = try payload.hashed()
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

        updatedHeaders["authorization"] = try generateAuthHeader(httpMethod, url: url, headers: updatedHeaders, bodyDigest: bodyDigest, dates: dates, region: region)

        var headers = HTTPHeaders()
        for (key, value) in updatedHeaders {
            headers.add(name: key, value: value)
        }

        return headers
    }
}
