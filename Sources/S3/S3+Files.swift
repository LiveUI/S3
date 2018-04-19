//
//  S3+Files.swift
//  S3
//
//  Created by Ondrej Rafaj on 01/12/2016.
//  Copyright © 2016 manGoweb UK Ltd. All rights reserved.
//

import Foundation
import Vapor


// Helper S3 extension for uploading files by their URL/path
public extension S3 {
    
    /// Upload file by it's URL to S3, full set
    public func put(file url: URL, destination: String, bucket: String? = nil, access: AccessControlList = .privateAccess, on req: Request) throws -> Future<File.Response> {
        let data: Data = try Data(contentsOf: url)
        let file = File.Upload(data: data, bucket: bucket, destination: destination, access: access, mime: mimeType(forFileAtUrl: url))
        return try put(file: file, on: req)
    }
    
    /// Upload file by it's path to S3, full set
    public func put(file path: String, destination: String, bucket: String? = nil, access: AccessControlList = .privateAccess, on req: Request) throws -> Future<File.Response> {
        let url: URL = URL(fileURLWithPath: path)
        return try put(file: url, destination: destination, bucket: bucket, access: access, on: req)
    }
    
}
