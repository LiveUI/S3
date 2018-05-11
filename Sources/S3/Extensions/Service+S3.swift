//
//  Service+S3.swift
//  S3Signer
//
//  Created by Ondrej Rafaj on 19/04/2018.
//

import Foundation
import Service
@_exported import S3Signer


extension Services {

    /// Convenience method to register both S3Signer and S3Client
    public mutating func register(s3 config: S3Signer.Config, defaultBucket: String) throws {
        try S3(defaultBucket: defaultBucket, config: config, services: &self)
    }

}
