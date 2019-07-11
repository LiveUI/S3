//
//  S3+Get.swift
//  S3
//
//  Created by Ondrej Rafaj on 11/05/2018.
//

import Foundation
import Vapor


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
    public func get(file: LocationConvertible, headers strHeaders: [String: String], on eventLoop: EventLoop) -> EventLoopFuture<File.Response> {
        let url: URL
        let headers: HTTPHeaders

        do {
            url = try makeURLBuilder().url(file: file)
            headers = try signer.headers(for: .GET, urlString: url.absoluteString, headers: strHeaders, payload: .none)
        } catch let error {
            return eventLoop.future(error: error)
        }

        return make(request: url, method: .GET, headers: headers, on: eventLoop).flatMapThrowing { response in
            try self.check(response)
            
            guard let data = response.body.data else {
                throw Error.missingData
            }
            
            let res = File.Response(data: data, bucket: file.bucket ?? self.defaultBucket, path: file.path, access: nil, mime: self.mimeType(forFileAtUrl: url))
            return res
        }
    }
    
    /// Retrieve file data from S3
    public func get(file: LocationConvertible, on eventLoop: EventLoop) -> EventLoopFuture<File.Response> {
        return get(file: file, headers: [:], on: eventLoop)
    }
    
}
