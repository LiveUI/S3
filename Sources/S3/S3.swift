import S3Signer
import Vapor

/// Main S3 class
public class S3: S3Client {    
    
    /// Error messages
    public enum Error: Swift.Error {
        case invalidUrl
        case errorResponse(HTTPResponseStatus, ErrorMessage)
        case badClientResponse(ClientResponse)
        case badResponse(Response)
        case badStringData
        case missingData
        case notFound
        case s3NotRegistered
    }
    
    /// If set, this bucket name value will be used globally unless overriden by a specific call
    public internal(set) var defaultBucket: String
    
    /// Signer instance
    public let signer: S3Signer
    
    let urlBuilder: URLBuilder?
    
    // MARK: Initialization
    
    /// Basic initialization method, also registers S3Signer and self with services
    @discardableResult public convenience init(defaultBucket: String, config: S3Signer.Config) throws {
        let signer = try S3Signer(config)
        try self.init(defaultBucket: defaultBucket, signer: signer)
    }
    
    /// Basic initialization method
    public init(defaultBucket: String, signer: S3Signer) throws {
        self.defaultBucket = defaultBucket
        self.signer = signer
        self.urlBuilder = nil
    }
    
    /// Basic initialization method
    public init(urlBuilder: URLBuilder, defaultBucket: String, signer: S3Signer) throws {
        self.defaultBucket = defaultBucket
        self.signer = signer
        self.urlBuilder = nil
    }
    
}

// MARK: - Helper methods

extension S3 {
    
    // QUESTION: Can we replace this with just Data()?
    /// Serve empty data
    func emptyData() -> Data {
        return Data("".utf8)
    }
    
    /// Check response for error
    @discardableResult func check(_ response: Response) throws -> Response {
        guard response.status == .ok || response.status == .noContent else {
            if let error = try? response.decode(to: ErrorMessage.self) {
                throw Error.errorResponse(response.status, error)
            } else {
                throw Error.badResponse(response)
            }
        }
        return response
    }

    /// Check response for error
    @discardableResult func check(_ response: ClientResponse) throws -> ClientResponse {
        guard response.status == .ok || response.status == .noContent else {
            if let error = try? response.content.decode(ErrorMessage.self) {
                throw Error.errorResponse(response.status, error)
            } else {
                throw Error.badClientResponse(response)
            }
        }
        return response
    }
    
    /// Get mime type for file
    static func mimeType(forFileAtUrl url: URL) -> String {
        guard let mediaType = HTTPMediaType.fileExtension(url.pathExtension) else {
            return HTTPMediaType(type: "application", subType: "octet-stream").description
        }
        return mediaType.description
    }
    
    /// Get mime type for file
    func mimeType(forFileAtUrl url: URL) -> String {
        return S3.mimeType(forFileAtUrl: url)
    }
    
    /// Create URL builder
    func makeURLBuilder() -> URLBuilder {
        return urlBuilder ?? S3URLBuilder(defaultBucket: defaultBucket, config: signer.config)
    }
    
}
