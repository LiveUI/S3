//
//  S3+Copy.swift
//  S3
//
//  Created by Topic, Zdenek on 17/10/2018.
//

import Foundation
import Vapor

extension S3 {
    
    /// Copy file on S3
    public func copy(file: LocationConvertible, to: LocationConvertible, headers: [String: String], on container: Container) throws -> EventLoopFuture<File.CopyResponse> {
        let builder = urlBuilder(for: container)
        let originPath = "\(file.bucket ?? defaultBucket)/\(file.path)"
        let destinationUrl = try builder.url(file: to)
        
        var awsHeaders: [String: String] = headers
        awsHeaders["x-amz-copy-source"] = originPath
        let headers = try signer.headers(
            for: .PUT,
            urlString: destinationUrl.absoluteString,
            headers: awsHeaders,
            payload: .none
        )
        
        let request = Request(using: container)
        request.http.method = .PUT
        request.http.headers = headers
        request.http.body = .empty
        request.http.url = destinationUrl
        
        let client = try container.make(Client.self)
        return client.send(request)
            .map {
                try self.check($0)
                return try $0.decode(to: File.CopyResponse.self)
            }
    }
    
}
