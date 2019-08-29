import Foundation
import NIO


// Helper S3 extension for deleting files by their URL/path
extension S3 {
    
    // MARK: Delete
    
    /// Delete file from S3
    public func delete(file: LocationConvertible, headers strHeaders: [String: String], on eventLoop: EventLoop) -> EventLoopFuture<Void> {
        let headers: HTTPHeaders
        let url: URL

        do {
            url = try makeURLBuilder().url(file: file)
            headers = try signer.headers(for: .DELETE, urlString: url.absoluteString, headers: strHeaders, payload: .none)
        } catch let error {
            return eventLoop.makeFailedFuture(error)
        }

        return make(request: url, method: .DELETE, headers: headers, data: nil, on: eventLoop).flatMapThrowing(self.check).map { _ in
            return Void()
        }
    }
    
    /// Delete file from S3
    public func delete(file: LocationConvertible, on eventLoop: EventLoop) -> EventLoopFuture<Void> {
        return
            delete(file: file, headers: [:], on: eventLoop)
    }
    
}
