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
    public func headers(for httpMethod: HTTPMethod, urlString: URLRepresentable, region: Region? = nil, headers: [String: String] = [:], payload: Payload) throws -> HTTPHeaders {
        guard let url = urlString.convertToURL() else {
            throw Error.badURL("\(urlString)")
        }
        
        let dates = getDates(Date())
        let bodyDigest = try payload.hashed()
        let region = region ?? config.region
        var updatedHeaders = update(headers: headers, url: url, longDate: dates.long, bodyDigest: bodyDigest, region: region)
        
        if httpMethod == .PUT && payload.isBytes {
            updatedHeaders["Content-MD5"] = try MD5.hash(payload.bytes).base64EncodedString()
        }
        
        if httpMethod == .PUT || httpMethod == .DELETE {
            updatedHeaders["Content-Length"] = payload.size()
            if httpMethod == .PUT && url.pathExtension != "" {
                updatedHeaders["Content-Type"] = url.pathExtension
            }
        }
        
        updatedHeaders["Authorization"] = try generateAuthHeader(httpMethod, url: url, headers: updatedHeaders, bodyDigest: bodyDigest, dates: dates, region: region)
        
        var headers = HTTPHeaders()
        for (key, value) in updatedHeaders {
            headers.add(name: key, value: value)
        }
        
        return headers
    }
    
    /// Create a pre-signed URL for later use
    public func presignedURLV4(httpMethod: HTTPMethod, url: URL, expiration: Expiration, region: Region? = nil, headers: [String: String]) throws -> URL? {
        let dates = Dates(Date())
        var updatedHeaders = headers
        
        let region = region ?? config.region
        
        updatedHeaders["Host"] = url.host ?? region.host
        
        let (canonRequest, fullURL) = try presignedURLCanonRequest(httpMethod, dates: dates, expiration: expiration, url: url, region: region, headers: updatedHeaders)
        
        let stringToSign = try createStringToSign(canonRequest, dates: dates, region: region)
        let signature = try createSignature(stringToSign, timeStampShort: dates.short, region: region)
        let presignedURL = URL(string: fullURL.absoluteString.appending("&X-Amz-Signature=\(signature)"))
        return presignedURL
    }
    
}
