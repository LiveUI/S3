//
//  LocationConvertible.swift
//  S3
//
//  Created by Ondrej Rafaj on 19/04/2018.
//

import Foundation


public protocol LocationConvertible {
    /// Override target bucket
    var s3bucket: String? { get }
    
    /// S3 file path
    var s3path: String { get }
}


/// String should be convertible into S3 path
extension String: LocationConvertible {
    
    /// Bucket name on a path, will be nil on a string
    public var s3bucket: String? {
        return nil
    }
    
    /// S3 file path
    public var s3path: String {
        return self
    }
    
}
