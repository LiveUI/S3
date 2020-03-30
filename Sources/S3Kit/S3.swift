import S3Signer
import Foundation
import HTTPMediaTypes
import AsyncHTTPClient


/// Main S3 class
public class S3: S3Client {    
    public let eventLoop: EventLoop
    public let httpClient: HTTPClient
    
    /// Error messages
    public enum Error: Swift.Error {
        case invalidUrl
        case errorResponse(HTTPResponseStatus, ErrorMessage)
        case badClientResponse(HTTPClient.Response)
        case badResponse(HTTPClient.Response)
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
    public convenience init(config: S3Signer.Config, eventLoop: EventLoop, httpClient: HTTPClient) {
        let signer = S3Signer(config)
        self.init(defaultBucket: config.defaultBucket, signer: signer, eventLoop: eventLoop, httpClient: httpClient)
    }
    
    /// Basic initialization method
    public init(defaultBucket: String, signer: S3Signer, eventLoop: EventLoop, httpClient: HTTPClient) {
        self.defaultBucket = defaultBucket
        self.signer = signer
        self.urlBuilder = nil
        self.eventLoop = eventLoop
        self.httpClient = httpClient
    }
    
    /// Basic initialization method
    public init(urlBuilder: URLBuilder, defaultBucket: String, signer: S3Signer, eventLoop: EventLoop, httpClient: HTTPClient) {
        self.defaultBucket = defaultBucket
        self.signer = signer
        self.urlBuilder = nil
        self.eventLoop = eventLoop
        self.httpClient = httpClient
    }
    
}

// MARK: - Helper methods

extension S3 {
    
    /// Check response for error
    @discardableResult func check(_ response: HTTPClient.Response) throws -> HTTPClient.Response {
        guard response.status == .ok || response.status == .noContent else {
            if let error = try? response.decode(to: ErrorMessage.self) {
                if var body = response.body, let content = body.readString(length: body.readableBytes) {
                    print(content)
                }
                throw Error.errorResponse(response.status, error)
            } else {
                if var body = response.body, let content = body.readString(length: body.readableBytes) {
                    print(content)
                }
                throw Error.badResponse(response)
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
