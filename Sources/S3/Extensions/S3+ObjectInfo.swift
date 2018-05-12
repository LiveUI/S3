//
//  S3+ObjectInfo.swift
//  S3
//
//  Created by Ondrej Rafaj on 12/05/2018.
//

import Foundation
import Vapor
import S3Signer


// Helper S3 extension for working with buckets
public extension S3 {
    
    // MARK: Buckets
    
    /// Get bucket location
    public func get(fileInfo file: LocationConvertible, headers: [String: String] = [:], on container: Container) throws -> Future<File.Response> {
        let signer = try container.makeS3Signer()
        
        let url = try self.url(file: file, on: container)
        
        let headers = try signer.headers(for: .HEAD, urlString: url.absoluteString, headers: headers, payload: .none)
        
        return try make(request: url, method: .HEAD, headers: headers, data: "".convertToData(), on: container).map(to: File.Response.self) { response in
            try self.check(response)
            
            return try response.decode(to: File.Response.self)
        }
    }
    
}
