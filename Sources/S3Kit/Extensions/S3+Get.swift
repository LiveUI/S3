import Foundation
import NIO

// Helper S3 extension for loading (getting) files by their URL/path
extension S3 {
    
    // MARK: URL
    
    /// File URL
    public func url(fileInfo file: LocationConvertible) throws -> URL {
        let builder = makeURLBuilder()
        let url = try builder.url(file: file)
        return url
    }
    
    // MARK: Get
    
    /// Retrieve file data from S3
    public func get(file: LocationConvertible, headers strHeaders: [String: String]) -> EventLoopFuture<File.Response> {
        let url: URL
        let headers: HTTPHeaders

        do {
            url = try makeURLBuilder().url(file: file)
            headers = try signer.headers(for: .GET, urlString: url.absoluteString, headers: strHeaders, payload: .none)
        } catch let error {
            return eventLoop.makeFailedFuture(error)
        }

        return make(request: url, method: .GET, headers: headers).flatMapThrowing { response in
            try self.check(response)
            
            guard var b = response.body, let data = b.readBytes(length: b.readableBytes) else {
                throw Error.missingData
            }
            
            let res = File.Response(data: Data(data), bucket: file.bucket ?? self.defaultBucket, path: file.path, access: nil, mime: self.mimeType(forFileAtUrl: url))
            return res
        }
    }
    
    /// Retrieve file data from S3
    public func get(file: LocationConvertible) -> EventLoopFuture<File.Response> {
        return get(file: file, headers: [:])
    }
    
}
