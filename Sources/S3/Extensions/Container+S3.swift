//
//  Container+S3.swift
//  S3
//
//  Created by Ondrej Rafaj on 19/04/2018.
//

import Foundation
import Vapor


extension Container {
    
    public func makeS3Client() throws -> S3Client {
        return try make()
    }
    
    public func makeS3() throws -> S3 {
        guard let s3 = try makeS3Client() as? S3 else {
            throw S3.Error.s3NotRegistered
        }
        return s3
    }
    
}
