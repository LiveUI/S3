//
//  S3+Bytes.swift
//  S3
//
//  Created by Ondrej Rafaj on 01/12/2016.
//  Copyright © 2016 manGoweb UK Ltd. All rights reserved.
//

import Foundation
import Vapor


public extension S3 {
    
    public func put(bytes: Bytes, filePath: String, bucketName: String, accessControl: AccessControlList = .privateAccess) throws {
        let data: Data = Data(bytes: bytes)
        try self.put(data: data, filePath: filePath, bucketName: bucketName, accessControl: accessControl)
    }
    
    public func put(bytes: Bytes, filePath: String, accessControl: AccessControlList = .privateAccess) throws {
        guard let bucketName = self.bucketName else {
            throw Error.missingBucketName
        }
        try self.put(bytes: bytes, filePath: filePath, bucketName: bucketName, accessControl: accessControl)
    }
    
}
