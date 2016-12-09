//
//  S3+Files.swift
//  S3
//
//  Created by Ondrej Rafaj on 01/12/2016.
//  Copyright © 2016 manGoweb UK Ltd. All rights reserved.
//

import Foundation


public extension S3 {
    
    public func put(fileAtUrl url: URL, filePath: String, bucketName: String, accessControl: AccessControlList = .privateAccess) throws {
        let data: Data = try Data.init(contentsOf: url)
        var headers: [String: String] = [:]
        headers["Content-Type"] = self.mimeType(forFileAtUrl: url)
        try self.put(data: data, filePath: filePath, bucketName: bucketName, headers: headers, accessControl: accessControl)
    }
    
    public func put(fileAtUrl url: URL, filePath: String, accessControl: AccessControlList = .privateAccess) throws {
        guard let bucketName = self.bucketName else {
            throw Error.missingBucketName
        }
        try self.put(fileAtUrl: url, filePath: filePath, bucketName: bucketName, accessControl: accessControl)
    }
    
    public func put(fileAtPath path: String, filePath: String, bucketName: String, accessControl: AccessControlList = .privateAccess) throws {
        let url: URL = URL(fileURLWithPath: path)
        try self.put(fileAtUrl: url, filePath: filePath, bucketName: bucketName, accessControl: accessControl)
    }
    
    public func put(fileAtPath path: String, filePath: String, accessControl: AccessControlList = .privateAccess) throws {
        let url: URL = URL(fileURLWithPath: path)
        try self.put(fileAtUrl: url, filePath: filePath, accessControl: accessControl)
    }
    
}
