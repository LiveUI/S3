import Foundation
import Vapor
import Crypto


/// S3 Client: All network calls to and from AWS' S3 servers
public final class S3Signer: Service {
    
    /// Errors
    public enum Error: Swift.Error {
        case badURL
        case invalidEncoding
    }
    
    /// S3 Configuration
    public struct Config: Service {
        
        /// AWS Access Key
        let accessKey: String
        
        /// AWS Secret Key
        let secretKey: String
        
        /// The region where S3 bucket is located.
        public let region: Region
        
        /// AWS Security Token. Used to validate temporary credentials, such as those from an EC2 Instance's IAM role
        let securityToken : String?
        
        /// AWS Service type
        let service: String = "s3"
        
        /// Initalizer
        public init(accessKey: String, secretKey: String, region: Region, securityToken: String? = nil) {
            self.accessKey = accessKey
            self.secretKey = secretKey
            self.region = region
            self.securityToken = securityToken
        }
        
    }
    
    /// Configuration
    public private(set) var config: Config
    
    /// Initializer
    public init(_ config: Config) throws {
        self.config = config
    }
    
}

extension S3Signer {
    
    public func headers(for httpMethod: HTTPMethod, urlString: String, headers: [String: String] = [:], payload: Payload) throws -> HTTPHeaders {
        guard let url = URL(string: urlString) else { throw S3Signer.Error.badURL }
        let dates = getDates(Date())
        let bodyDigest = try payload.hashed()
        var updatedHeaders = updateHeaders(headers, url: url, longDate: dates.long, bodyDigest: bodyDigest)
        
        if httpMethod == .PUT && payload.isBytes {
            // TODO: Figure out why S3 would fail with this
            updatedHeaders["Content-MD5"] = try MD5.hash(payload.bytes).base64EncodedString()
        }
        
        updatedHeaders["Authorization"] = try self.headers(httpMethod, url: url, headers: updatedHeaders, bodyDigest: bodyDigest, dates: dates)
        
        if httpMethod == .PUT {
            updatedHeaders["Content-Length"] = payload.size()
            if url.pathExtension != "" {
                updatedHeaders["Content-Type"] = url.pathExtension
            }
        }
        
        if payload.isUnsigned {
            updatedHeaders["x-amz-content-sha256"] = bodyDigest
        }
        
        var headers = HTTPHeaders()
        for (key, value) in updatedHeaders {
            headers.add(name: key, value: value)
        }
        
        return headers
    }
}

extension S3Signer {
    
    private func canonicalHeaders(_ headers: [String: String]) -> String {
        let headerList = Array(headers.keys)
            .map { "\($0.lowercased()):\(headers[$0]!)" }
            .filter { $0 != "authorization" }
            .sorted(by: { $0.localizedCompare($1) == ComparisonResult.orderedAscending })
            .joined(separator: "\n")
            .appending("\n")
        return headerList
    }
    
    private func createCanonicalRequest(_ httpMethod: HTTPMethod, url: URL, headers: [String: String], bodyDigest: String) throws -> String {
        return try [httpMethod.description, path(url), query(url), canonicalHeaders(headers),signedHeaders(headers), bodyDigest].joined(separator: "\n")
    }
    
    private func createSignature(_ stringToSign: String, timeStampShort: String) throws -> String {
        let dateKey = try HMAC.SHA256.authenticate(timeStampShort.convertToData(), key: "AWS4\(config.secretKey)".convertToData())
        let dateRegionKey = try HMAC.SHA256.authenticate(config.region.rawValue.convertToData(), key: dateKey)
        let dateRegionServiceKey = try HMAC.SHA256.authenticate(config.service.convertToData(), key: dateRegionKey)
        let signingKey = try HMAC.SHA256.authenticate("aws4_request".convertToData(), key: dateRegionServiceKey)
        let signature = try HMAC.SHA256.authenticate(stringToSign.convertToData(), key: signingKey)
        return signature.hexEncodedString()
    }
    
    private func createStringToSign(_ canonicalRequest: String, dates: Dates) throws -> String {
        let canonRequestHash = try SHA256.hash(canonicalRequest.convertToData()).hexEncodedString()
        return ["AWS4-HMAC-SHA256", dates.long, credentialScope(dates.short), canonRequestHash].joined(separator: "\n")
    }
    
    private func credentialScope(_ timeStampShort: String) -> String {
        return [timeStampShort, config.region.rawValue, config.service, "aws4_request"].joined(separator: "/")
    }
    
    private func headers(_ httpMethod: HTTPMethod, url: URL, headers: [String: String], bodyDigest: String, dates: Dates) throws -> String {
        let canonicalRequestHex = try createCanonicalRequest(httpMethod, url: url, headers: headers, bodyDigest: bodyDigest)
        let stringToSign = try createStringToSign(canonicalRequestHex, dates: dates)
        let signature = try createSignature(stringToSign, timeStampShort: dates.short)
        let authHeader = "AWS4-HMAC-SHA256 Credential=\(config.accessKey)/\(credentialScope(dates.short)), SignedHeaders=\(signedHeaders(headers)), Signature=\(signature)"
        return authHeader
    }
    
    private func getDates(_ date: Date) -> Dates {
        return Dates(date)
    }

    private func path(_ url: URL) -> String {
        return !url.path.isEmpty ? url.path.awsStringEncoding(AWSEncoding.PathAllowed) ?? "/" : "/"
    }
    
    private func presignedURLCanonRequest(_ httpMethod: HTTPMethod, dates: Dates, expiration: Expiration, url: URL, headers: [String: String]) throws -> (String, URL) {
        guard let credScope = credentialScope(dates.short).awsStringEncoding(AWSEncoding.QueryAllowed),
            let signHeaders = signedHeaders(headers).awsStringEncoding(AWSEncoding.QueryAllowed) else { throw S3Signer.Error.invalidEncoding }
        let fullURL = "\(url.absoluteString)?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=\(config.accessKey)%2F\(credScope)&X-Amz-Date=\(dates.long)&X-Amz-Expires=\(expiration.value)&X-Amz-SignedHeaders=\(signHeaders)"
        
        // This should never throw.
        guard let url = URL(string: fullURL) else {
            throw S3Signer.Error.badURL
        }
        
        return try ([httpMethod.description, path(url), query(url), canonicalHeaders(headers), signedHeaders(headers), "UNSIGNED-PAYLOAD"].joined(separator: "\n"), url)
    }
    
    private func query(_ url: URL) throws -> String {
        if let queryItems = URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems {
            let items = queryItems.map({ ($0.name.awsStringEncoding(AWSEncoding.QueryAllowed) ?? "", $0.value?.awsStringEncoding(AWSEncoding.QueryAllowed) ?? "") })
            let encodedItems = items.map({ "\($0.0)=\($0.1)" })
            return encodedItems.sorted().joined(separator: "&")
        }
        return ""
    }
    
    private func signedHeaders(_ headers: [String: String]) -> String {
        let headerList = Array(headers.keys).map { $0.lowercased() }.filter { $0 != "authorization" }.sorted().joined(separator: ";")
        return headerList
    }

    private func updateHeaders(_ headers: [String: String], url: URL, longDate: String, bodyDigest: String) -> [String: String] {
        var updatedHeaders = headers
        updatedHeaders["X-Amz-Date"] = longDate
        updatedHeaders["Host"] = url.host ?? config.region.host
        
        if bodyDigest != "UNSIGNED-PAYLOAD" && config.service == "s3" {
            updatedHeaders["x-amz-content-sha256"] = bodyDigest
        }
        // According to http://docs.aws.amazon.com/IAM/latest/UserGuide/id_credentials_temp_use-resources.html#RequestWithSTS
        if let token = config.securityToken {
            updatedHeaders["X-Amz-Security-Token"] = token
        }
        return updatedHeaders
    }
    
}
