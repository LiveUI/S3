//
//  Services+S3Mock.swift
//  S3TestTools
//
//  Created by Ondrej Rafaj on 19/04/2018.
//

import Foundation
import Service
import S3Signer
import S3


extension Services {
    
    public mutating func registerS3Mock() throws {
        register(S3Mock(), as: S3Client.self)
    }
    
}
