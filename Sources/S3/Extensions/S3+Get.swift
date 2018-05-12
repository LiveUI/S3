//
//  S3+Get.swift
//  S3
//
//  Created by Ondrej Rafaj on 11/05/2018.
//

import Foundation
import Vapor


// Helper S3 extension for loading (getting) files by their URL/path
public extension S3 {
    
    // MARK: Get
    
    /// Retrieve file data from S3
    public func get(file: LocationConvertible, headers: [String: String] = [:], on container: Container) throws -> Future<File.Response> {
        let signer = try container.makeS3Signer()
        
        let url = try self.url(file: file, on: container)
        
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
