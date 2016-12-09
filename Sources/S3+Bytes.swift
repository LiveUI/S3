//
//  S3+Bytes.swift
//  S3
//
//  Created by Ondrej Rafaj on 01/12/2016.
//  Copyright © 2016 manGoweb UK Ltd. All rights reserved.
//

import Foundation
import Vapor


/**
 Helper S3 extension for uploading Bytes data
 */
public extension S3 {
    
    /**
     Upload bytes file to S3, full set
     
     - Parameters:
     - bytes: File bytes
     - filePath: Path to a file within the bucket (image.jpg)
     - bucketName: Name of the bucket to be used (global bucket value will be ignored)
     - accessControl: Access control list value (default .privateAccess)
     */
    public func put(bytes: Bytes, filePath: String, bucketName: String, accessControl: AccessControlList = .privateAccess) throws {
        let data: Data = Data(bytes: bytes)
        try self.put(data: data, filePath: filePath, bucketName: bucketName, accessControl: accessControl)
    }
    
    /**
     Upload bytes file to S3, using global bucket name
     
     - Parameters:
     - bytes: File bytes
     - filePath: Path to a file within the bucket (image.jpg)
     - accessControl: Access control list value (default .privateAccess)
     */
    public func put(bytes: Bytes, filePath: String, accessControl: AccessControlList = .privateAccess) throws {
        guard let bucketName = self.bucketName else {
            throw Error.missingBucketName
        }
        try self.put(bytes: bytes, filePath: filePath, bucketName: bucketName, accessControl: accessControl)
    }
    
}
