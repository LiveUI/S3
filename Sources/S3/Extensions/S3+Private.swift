//
//  S3+Private.swift
//  S3
//
//  Created by Ondrej Rafaj on 19/04/2018.
//

import Foundation
import Vapor

extension S3 {
    
    /// Make an S3 request
    func make(request url: URL, method: HTTPMethod, headers: HTTPHeaders, data: Data? = nil, cachePolicy: URLRequest.CachePolicy = .useProtocolCachePolicy, on eventLoop: EventLoop) -> EventLoopFuture<Response> {
        var request = URLRequest(url: url, cachePolicy: cachePolicy)
        request.httpMethod = method.string
        request.httpBody = data
        headers.forEach { key, val in
            request.addValue(val, forHTTPHeaderField: key.description)
        }
        
        return execute(request, on: eventLoop)
    }

    func execute(_ request: ClientRequest, on eventLoop: EventLoop) -> EventLoopFuture<Response> {
        guard let url = URL(string: request.url.string) else {
            return eventLoop.future(error: Abort(.internalServerError, reason: "Found an invalid URL"))
        }

        var urlRequest = URLRequest(url: url, cachePolicy: .useProtocolCachePolicy)
        urlRequest.httpMethod = request.method.rawValue
        urlRequest.httpBody = Data(request.body!.readableBytesView)
        request.headers.forEach { key, value in
            urlRequest.addValue(value, forHTTPHeaderField: key)
        }

        return self.execute(urlRequest, on: eventLoop)
    }

    /// Execute given request with URLSession.shared
    func execute(_ request: URLRequest, on eventLoop: EventLoop) -> EventLoopFuture<Response> {
        let promise = eventLoop.makePromise(of: Response.self)
        
        URLSession.shared.dataTask(with: request, completionHandler: { (data, urlResponse, error) in
            if let error = error {
                promise.fail(error)
                return
            }
            
            guard let httpResponse = urlResponse as? HTTPURLResponse else {
                promise.fail(Abort(.internalServerError, reason: "URLResponse was not a HTTPURLResponse."))
                return
            }
            
            promise.succeed(S3.convert(foundationResponse: httpResponse, data: data))
        }).resume()
        
        return promise.futureResult
    }

    /// Convert given response and data to HTTPResponse from Vapors HTTP package
    static func convert(foundationResponse httpResponse: HTTPURLResponse, data: Data?) -> Response {
        let response = Response(status: .init(statusCode: httpResponse.statusCode))
        if let data = data {
            response.body = Response.Body(data: data)
        }
        for (key, value) in httpResponse.allHeaderFields {
            response.headers.replaceOrAdd(name: "\(key)", value: "\(value)")
        }
        return response
    }
    
}
