import Foundation
import Crypto
import NIOHTTP1
import WebErrorKit


/// S3 Client: All network calls to and from AWS' S3 servers
public final class S3Signer {
    
    /// Errors
    public enum Error: SerializableWebError {
        
        case badURL(String)
        case invalidEncoding
        case featureNotAvailableWithV2Signing
        
        public var serializedCode: String {
            switch self {
            case .badURL:
                return "s3.bad_url"
            case .invalidEncoding:
                return "s3.invalid_encoding"
            case .featureNotAvailableWithV2Signing:
                return "s3.not_available_on_v2_signing"
            }
        }
        
        public var reason: String {
            switch self {
            case .badURL(let url):
                return "Invalid URL: \(url)"
            case .invalidEncoding:
                return "Invalid encoding"
            case .featureNotAvailableWithV2Signing:
                return "Feature is not available on V2 signing"
            }
        }
        
    }

    /// S3 authentication support version
    public enum Version {
        case v2
        case v4
    }
    
    /// S3 Configuration
    public struct Config {
        
        /// AWS authentication version
        let authVersion: Version

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
        /// - Parameter accessKey: S3 access token
        /// - Parameter secretKey: S3 secret
        /// - Parameter region: Region
        /// - Parameter version: Signing version
        /// - Parameter securityToken: Temporary security token
        public init(accessKey: String, secretKey: String, region: Region, version: Version = .v4, securityToken: String? = nil) {
            self.accessKey = accessKey
            self.secretKey = secretKey
            self.region = region
            self.securityToken = securityToken
            self.authVersion = version
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
    /// - Parameter httpMethod: HTTP method
    /// - Parameter urlString: URL
    /// - Parameter region: Region
    /// - Parameter bucket: Bucket (default will be used if nil)
    /// - Parameter headers: Headers to sign
    /// - Parameter payload: Payload
    public func headers(for httpMethod: HTTPMethod, urlString: String, region: Region? = nil, bucket: String? = nil, headers: [String: String] = [:], payload: Payload) throws -> HTTPHeaders {
        return try self.headers(for: httpMethod, urlString: urlString, region: region, bucket: bucket, headers: headers, payload: payload, dates: Dates(Date()))
    }
    
    
    /// Create a pre-signed URL for later use
    /// - Parameter httpMethod: HTTP method
    /// - Parameter url: URL
    /// - Parameter expiration: Expiration time
    /// - Parameter region: AWS Region
    /// - Parameter headers: Headers to sign
    public func presignedURL(for httpMethod: HTTPMethod, url: URL, expiration: Expiration, region: Region? = nil, headers: [String: String] = [:]) throws -> URL? {
        return try presignedURL(for: httpMethod, url: url, expiration: expiration, region: region, headers: headers, dates: Dates(Date()))
    }
    
}
