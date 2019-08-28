import Foundation
import NIO
import AsyncHTTPClient


extension S3 {
    
    /// Make an S3 request
    func make(request url: URL, method: HTTPMethod, headers: HTTPHeaders, data: Data? = nil, cachePolicy: URLRequest.CachePolicy = .useProtocolCachePolicy, on eventLoop: EventLoop) -> EventLoopFuture<HTTPClient.Response> {
        do {
            let body: HTTPClient.Body?
            if let data = data {
                body = HTTPClient.Body.data(data)
            } else {
                body = nil
            }
            
            let request = try HTTPClient.Request(
                url: url.absoluteString,
                method: method,
                headers: headers,
                body: body
            )
            
            let client = HTTPClient(eventLoopGroupProvider: .shared(eventLoop))
            return client.execute(request: request)
        } catch {
            return eventLoop.makeFailedFuture(error)
        }
    }
    
}
