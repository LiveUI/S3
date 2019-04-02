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
    public func url(fileInfo file: LocationConvertible, on container: Container) throws -> URL {
        let builder = urlBuilder(for: container)
        let url = try builder.url(file: file)
        return url
    }
    
    // MARK: Get
    
    /// Retrieve file data from S3
    public func get(file: LocationConvertible, headers: [String: String], on container: Container) throws -> Future<File.Response> {
        let builder = urlBuilder(for: container)
        let url = try builder.url(file: file)
        
        let headers = try signer.headers(for: .GET, urlString: url.absoluteString, headers: headers, payload: .none)
        return try make(request: url, method: .GET, headers: headers, on: container).map(to: File.Response.self) { response in
            try self.check(response)
            
            guard let data = response.http.body.data else {
                throw Error.missingData
            }
            
            let res = File.Response(data: data, bucket: file.bucket ?? self.defaultBucket, path: file.path, access: nil, mime: self.mimeType(forFileAtUrl: url))
            return res
        }
    }
    
    /// Retrieve file data from S3
    public func get(file: LocationConvertible, on container: Container) throws -> EventLoopFuture<File.Response> {
        return try get(file: file, headers: [:], on: container)
    }
    
}
