//
//  S3+Delete.swift
//  S3
//
//  Created by Ondrej Rafaj on 11/05/2018.
//

import Foundation
import Vapor


// Helper S3 extension for deleting files by their URL/path
extension S3 {
    
    // MARK: Delete
    
    /// Delete file from S3
    public func delete(file: LocationConvertible, headers: [String: String], on container: Container) throws -> Future<Void> {
        let builder = urlBuilder(for: container)
        let url = try builder.url(file: file)
        
        let headers = try signer.headers(for: .DELETE, urlString: url.absoluteString, headers: headers, payload: .none)
        return try make(request: url, method: .DELETE, headers: headers, data: emptyData(), cachePolicy: .reloadIgnoringLocalCacheData, on: container).map(to: Void.self) { response in
            try self.check(response)
            
            return Void()
        }
    }
    
    /// Delete file from S3
    public func delete(file: LocationConvertible, on container: Container) throws -> Future<Void> {
        return try delete(file: file, headers: [:], on: container)
    }
    
}
