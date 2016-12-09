//
//  S3+Strings.swift
//  S3
//
//  Created by Ondrej Rafaj on 01/12/2016.
//  Copyright © 2016 manGoweb UK Ltd. All rights reserved.
//

import Foundation


public extension S3 {
    
    /**
     Upload file content to S3, full set
     
     - Parameters:
     - string: File content
     - filePath: Path to a file within the bucket (image.jpg)
     - bucketName: Name of the bucket to be used (global bucket value will be ignored)
     - contentType: Mime type of the uploaded file (Example: text/plain)
     - accessControl: Access control list value (default .privateAccess)
     */
    public func put(string: String, filePath: String, bucketName: String, contentType: String? = nil, accessControl: AccessControlList = .privateAccess) throws {
        guard let data: Data = string.data(using: String.Encoding.utf8) else {
            throw Error.badStringData
        }
        var headers: [String: String] = [:]
        if contentType == nil {
            headers["Content-Type"] = "text/plain"
        }
        else {
            headers["Content-Type"] = contentType
        }
        try self.put(data: data, filePath: filePath, bucketName: bucketName, headers: headers, accessControl: accessControl)
    }
    
    /**
     Upload file content to S3, full set
     
     - Parameters:
     - string: File content
     - filePath: Path to a file within the bucket (image.jpg)
     - bucketName: Name of the bucket to be used (global bucket value will be ignored)
     - accessControl: Access control list value (default .privateAccess)
     */
    public func put(string: String, filePath: String, bucketName: String, accessControl: AccessControlList) throws {
        try self.put(string: string, filePath: filePath, bucketName: bucketName, contentType: nil, accessControl: accessControl)
    }
    
    /**
     Upload file content to S3, basic set
     
     - Parameters:
     - string: File content
     - filePath: Path to a file within the bucket (image.jpg)
     - accessControl: Access control list value (default .privateAccess)
     */
    public func put(string: String, filePath: String, accessControl: AccessControlList = .privateAccess) throws {
        guard let bucketName = self.bucketName else {
            throw Error.missingBucketName
        }
        try self.put(string: string, filePath: filePath, bucketName: bucketName, contentType: nil, accessControl: accessControl)
    }
    
}
