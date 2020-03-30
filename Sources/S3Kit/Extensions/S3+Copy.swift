import Foundation
import NIO
import AsyncHTTPClient


extension S3 {
    
    // MARK: Copy
    
    /// Copy file on S3
    public func copy(file: LocationConvertible, to: LocationConvertible, headers strHeaders: [String: String]) -> EventLoopFuture<File.CopyResponse> {
        do {
            let destinationUrl = try makeURLBuilder().url(file: to)

            var awsHeaders: [String: String] = strHeaders
            awsHeaders["x-amz-copy-source"] = "\(file.bucket ?? defaultBucket)/\(file.path)"
            let headers = try signer.headers(
                for: .PUT,
                urlString: destinationUrl.absoluteString,
                headers: awsHeaders,
                payload: .none
            )
            
            return make(request: destinationUrl, method: .PUT, headers: headers).flatMapThrowing { response in
                return try self.check(response).decode(to: File.CopyResponse.self)
            }
        } catch let error {
            return eventLoop.makeFailedFuture(error)
        }
    }
    
}
