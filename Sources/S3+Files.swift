//
//  S3+Files.swift
//  S3
//
//  Created by Ondrej Rafaj on 01/12/2016.
//  Copyright © 2016 manGoweb UK Ltd. All rights reserved.
//

import Foundation


/**
 Helper S3 extension for uploading files by their URL/path
 */
public extension S3 {
    
    /**
     Upload file by it's URL to S3, full set
     
     - Parameters:
     - fileAtUrl: File URL
     - filePath: Path to a file within the bucket (image.jpg)
     - bucketName: Name of the bucket to be used (global bucket value will be ignored)
     - accessControl: Access control list value (default .privateAccess)
     */
    public func put(fileAtUrl url: URL, filePath: String, bucketName: String, accessControl: AccessControlList = .privateAccess) throws {
        let data: Data = try Data.init(contentsOf: url)
        var headers: [String: String] = [:]
        headers["Content-Type"] = self.mimeType(forFileAtUrl: url)
        try self.put(data: data, filePath: filePath, bucketName: bucketName, headers: headers, accessControl: accessControl)
    }
    
    /**
     Upload file by it's URL to S3, using global bucket name
     
     - Parameters:
     - fileAtUrl: File URL
     - filePath: Path to a file within the bucket (image.jpg)
     - accessControl: Access control list value (default .privateAccess)
     */
    public func put(fileAtUrl url: URL, filePath: String, accessControl: AccessControlList = .privateAccess) throws {
        guard let bucketName = self.bucketName else {
            throw Error.missingBucketName
        }
        try self.put(fileAtUrl: url, filePath: filePath, bucketName: bucketName, accessControl: accessControl)
    }
    
    /**
     Upload file by it's path to S3, full set
     
     - Parameters:
     - fileAtPath: File path
     - filePath: Path to a file within the bucket (image.jpg)
     - bucketName: Name of the bucket to be used (global bucket value will be ignored)
     - accessControl: Access control list value (default .privateAccess)
     */
    public func put(fileAtPath path: String, filePath: String, bucketName: String, accessControl: AccessControlList = .privateAccess) throws {
        let url: URL = URL(fileURLWithPath: path)
        try self.put(fileAtUrl: url, filePath: filePath, bucketName: bucketName, accessControl: accessControl)
    }
    
    /**
     Upload file by it's path to S3, using global bucket name
     
     - Parameters:
     - fileAtPath: File path
     - filePath: Path to a file within the bucket (image.jpg)
     - accessControl: Access control list value (default .privateAccess)
     */
    public func put(fileAtPath path: String, filePath: String, accessControl: AccessControlList = .privateAccess) throws {
        let url: URL = URL(fileURLWithPath: path)
        try self.put(fileAtUrl: url, filePath: filePath, accessControl: accessControl)
    }
    
}
