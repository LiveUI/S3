//
//  S3+Strings.swift
//  S3
//
//  Created by Ondrej Rafaj on 01/12/2016.
//  Copyright © 2016 manGoweb UK Ltd. All rights reserved.
//

import Foundation
import Vapor


public extension S3 {
    
    /// Upload file content to S3, full set
    public func put(string: String, mime: MediaType = .plainText, destination: String, bucket: String? = nil, access: AccessControlList = .privateAccess, on req: Request) throws -> Future<File.Response> {
        guard let data: Data = string.data(using: String.Encoding.utf8) else {
            throw Error.badStringData
        }
        let file = File.Upload(data: data, bucket: bucket, destination: destination, access: access, mime: mime)
        return try put(file: file, on: req)
    }
    
}
