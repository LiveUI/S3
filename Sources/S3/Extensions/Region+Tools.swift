//
//  Region+Tools.swift
//  S3Signer
//
//  Created by Ondrej Rafaj on 19/04/2018.
//

import Foundation
@_exported import S3Signer


extension Region {
    
    public func urlString(bucket: String) -> String {
        return host + bucket
    }
    
    public func url(bucket: String) -> URL? {
        return URL(string: urlString(bucket: bucket))
    }
    
}
