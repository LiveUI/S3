//
//  URLBuilder.swift
//  S3
//
//  Created by Ondrej Rafaj on 16/05/2018.
//

import Foundation
import Vapor
import S3Signer


extension Region {
    
    /// Host URL including scheme
    public func hostUrlString(bucket: String? = nil) -> String {
        var bucket = bucket
        if let b = bucket {
            bucket = b + "."
        }
        return "https://" + (bucket ?? "") + host.finished(with: "/")
    }
    
}





/// URL builder
public protocol URLBuilder {
    
    /// Initializer
    init(_ container: Container, defaultBucket: String, config: S3Signer.Config)
    
    /// Plain Base URL with no bucket specified
    ///     *Format: https://s3.eu-west-2.amazonaws.com/
    func plain(region: Region?) throws -> URL
    
    /// Base URL for S3 region
    ///     *Format: https://bucket.s3.eu-west-2.amazonaws.com/path_or_parameter*
    func url(region: Region?, bucket: String?, path: String?) throws -> URL
    
    /// Base URL for a file in a bucket
    /// * Format: https://s3.eu-west-2.amazonaws.com/bucket/file.txt
    ///     * We can't have a bucket in the host or DELETE will attempt to delete the bucket, not file!
    func url(file: LocationConvertible) throws -> URL
    
}
