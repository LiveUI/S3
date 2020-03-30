import Foundation


// Helper S3 extension for working with services
extension S3 {
    
    // MARK: Buckets
    
    /// Get list of buckets
    public func buckets() -> EventLoopFuture<BucketsInfo> {
        let headers: HTTPHeaders
        let url: URL

        do {
            url = try makeURLBuilder().plain(region: nil)
            headers = try signer.headers(for: .GET, urlString: url.absoluteString, payload: .none)
        } catch let error {
            return eventLoop.makeFailedFuture(error)
        }

        return make(request: url, method: .GET, headers: headers, data: Data()).flatMapThrowing { response in
            try self.check(response)
            return try response.decode(to: BucketsInfo.self)
        }
    }
    
}
