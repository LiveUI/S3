import Foundation
import NIO
import AsyncHTTPClient


extension S3 {
    
    /// Make an S3 request
    func make(request url: URL, method: HTTPMethod, headers: HTTPHeaders, data: Data? = nil, cachePolicy: URLRequest.CachePolicy = .useProtocolCachePolicy) -> EventLoopFuture<HTTPClient.Response> {
        do {
            let body: HTTPClient.Body?
            if let data = data {
                body = HTTPClient.Body.data(data)
            } else {
                body = nil
            }
            
            var headers = headers
            headers.add(name: "User-Agent", value: "S3Kit-for-Swift")
            headers.add(name: "Accept", value: "*/*")
            headers.add(name: "Connection", value: "keep-alive")
            headers.add(name: "Content-Length", value: String(data?.count ?? 0))
            
            let request = try HTTPClient.Request(
                url: url.absoluteString,
                method: method,
                headers: headers,
                body: body
            )
            
            return httpClient.execute(request: request, eventLoop: .delegate(on: eventLoop))
        } catch {
            return eventLoop.makeFailedFuture(error)
        }
    }
    
}
