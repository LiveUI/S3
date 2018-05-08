//
//  S3+Private.swift
//  S3
//
//  Created by Ondrej Rafaj on 19/04/2018.
//

import Foundation
import Vapor
import HTTP


extension S3 {
    
    func make(request url: URL, method: HTTPMethod, headers: HTTPHeaders, data: Data? = nil, on container: Container) throws -> Future<Response> {
        let client = try container.make(Client.self)
        let request = Request(using: container)
        request.http.method = method
        request.http.headers = headers
        if let data = data {
            request.http.body = HTTPBody(data: data)
        }
        request.http.url = url
        return client.send(request)
    }
    
}
