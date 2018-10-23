import Foundation
import Vapor
import HTTP

extension S3 {
    
    /// Make an S3 request
    func make(request url: URL, method: HTTPMethod, headers: HTTPHeaders, data: Data? = nil, cachePolicy: URLRequest.CachePolicy = .useProtocolCachePolicy, on container: Container) throws -> Future<Response> {
        var request = URLRequest(url: url, cachePolicy: cachePolicy)
        request.httpMethod = method.string
        request.httpBody = data
        headers.forEach { key, val in
            request.addValue(val, forHTTPHeaderField: key.description)
        }
        
        return execute(request, on: container)
    }
    
    /// Execute given request with URLSession.shared
    func execute(_ request: URLRequest, on container: Container) -> Future<Response> {
        let promise = container.eventLoop.newPromise(Response.self)
        
        URLSession.shared.dataTask(with: request, completionHandler: { (data, urlResponse, error) in
            if let error = error {
                promise.fail(error: error)
                return
            }
            
            guard let httpResponse = urlResponse as? HTTPURLResponse else {
                let error = VaporError(identifier: "httpURLResponse", reason: "URLResponse was not a HTTPURLResponse.")
                promise.fail(error: error)
                return
            }
            
            let response = S3.convert(foundationResponse: httpResponse, data: data, on: container)
            
            promise.succeed(result: Response(http: response, using: container))
        }).resume()
        
        return promise.futureResult
    }
    
    /// Convert given response and data to HTTPResponse from Vapors HTTP package
    static func convert(foundationResponse httpResponse: HTTPURLResponse, data: Data?, on worker: Worker) -> HTTPResponse {
        var response = HTTPResponse(status: .init(statusCode: httpResponse.statusCode))
        if let data = data {
            response.body = HTTPBody(data: data)
        }
        for (key, value) in httpResponse.allHeaderFields {
            response.headers.replaceOrAdd(name: "\(key)", value: "\(value)")
        }
        return response
    }
    
}
