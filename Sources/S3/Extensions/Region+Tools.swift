//
//  Region+Tools.swift
//  S3Signer
//
//  Created by Ondrej Rafaj on 19/04/2018.
//

import Foundation
@_exported import S3Signer


extension Region {
    
    /// Get S3 URL string for bucket
    public func urlString(bucket: String, config: S3Signer.Config?) -> String {
        return host(config) + bucket
    }
    
    /// Get S3 URL for bucket
    public func url(bucket: String, config: S3Signer.Config?) -> URL? {
        return URL(string: urlString(bucket: bucket, config: config))
    }
    
}
