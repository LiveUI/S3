import Foundation
import Service
import HTTP
import Crypto


/// S3 Client: All network calls to and from AWS' S3 servers
public final class S3Signer: Service {
    
    /// Errors
    public enum Error: Swift.Error {
        case badURL(String)
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
    
    /// Generates auth headers for Simple Storage Services
    public func headers(for httpMethod: HTTPMethod, urlString: URLRepresentable, headers: [String: String] = [:], payload: Payload) throws -> HTTPHeaders {
        guard let url = urlString.convertToURL() else {
            throw Error.badURL("\(urlString)")
        }
        
        let dates = getDates(Date())
        let bodyDigest = try payload.hashed()
        var updatedHeaders = update(headers: headers, url: url, longDate: dates.long, bodyDigest: bodyDigest)
        
        if httpMethod == .PUT && payload.isBytes {
            updatedHeaders["Content-MD5"] = try MD5.hash(payload.bytes).base64EncodedString()
        }
        
        updatedHeaders["Authorization"] = try generateAuthHeader(httpMethod, url: url, headers: updatedHeaders, bodyDigest: bodyDigest, dates: dates)
        
        if httpMethod == .PUT || httpMethod == .DELETE {
            updatedHeaders["Content-Length"] = payload.size()
            if httpMethod == .PUT && url.pathExtension != "" {
                updatedHeaders["Content-Type"] = url.pathExtension
            } else if httpMethod == .DELETE {
                updatedHeaders.removeValue(forKey: "X-Amz-Date")
            }
        }
        
//        if payload.isUnsigned {
//            updatedHeaders["X-Amz-Content-SHA256"] = bodyDigest
//        }
        
        var headers = HTTPHeaders()
        for (key, value) in updatedHeaders {
            headers.add(name: key, value: value)
        }
        
        return headers
    }
    
    /// Create a pre-signed URL for later use
    public func presignedURLV4(httpMethod: HTTPMethod, url: URL, expiration: Expiration, headers: [String: String]) throws -> URL? {
        let dates = Dates(Date())
        var updatedHeaders = headers
        updatedHeaders["Host"] = url.host ?? config.region.host
        
        let (canonRequest, fullURL) = try presignedURLCanonRequest(httpMethod, dates: dates, expiration: expiration, url: url, headers: updatedHeaders)
        
        let stringToSign = try createStringToSign(canonRequest, dates: dates)
        let signature = try createSignature(stringToSign, timeStampShort: dates.short)
        let presignedURL = URL(string: fullURL.absoluteString.appending("&X-Amz-Signature=\(signature)"))
        return presignedURL
    }
    
}
