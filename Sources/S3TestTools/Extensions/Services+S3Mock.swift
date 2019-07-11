//
//  Services+S3Mock.swift
//  S3TestTools
//
//  Created by Ondrej Rafaj on 19/04/2018.
//

import Foundation
import Vapor
import S3Signer
import S3


extension Vapor.Services {
    public mutating func registerS3Mock() throws {
        try self.instance(S3Client.self, S3Mock())
    }
    
}
