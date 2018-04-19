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
    
}
