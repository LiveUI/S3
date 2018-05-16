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
class URLBuilder {
    
    /// Container
    let container: Container
    
    /// Default bucket
    let defaultBucket: String
    
    /// S3 Configuration
    let config: S3Signer.Config
    
    /// Initializer
    init(_ container: Container, defaultBucket: String, config: S3Signer.Config) {
        self.container = container
        self.defaultBucket = defaultBucket
        self.config = config
    }
    
    /// Plain Base URL with no bucket specified
    ///     *Format: https://s3.eu-west-2.amazonaws.com/
    func plain(region: Region? = nil) throws -> URL {
        let urlString = (region ?? config.region).hostUrlString()
        guard let url = URL(string: urlString) else {
            throw S3.Error.invalidUrl
        }
        return url
    }
    
    /// Base URL for S3 region
    ///     *Format: https://bucket.s3.eu-west-2.amazonaws.com/path_or_parameter*
    func url(region: Region? = nil, bucket: String? = nil, path: String? = nil) throws -> URL {
        let urlString = (region ?? config.region).hostUrlString(bucket: (bucket ?? defaultBucket))
        guard let url = URL(string: urlString) else {
            throw S3.Error.invalidUrl
        }
        return url
    }
    
    /// Base URL for a file in a bucket
    /// * Format: https://s3.eu-west-2.amazonaws.com/bucket/file.txt
    ///     * We can't have a bucket in the host or DELETE will attempt to delete the bucket, not file!
    func url(file: LocationConvertible) throws -> URL {
        let urlString = (file.region ?? config.region).hostUrlString()
        guard let url = URL(string: urlString)?.appendingPathComponent(file.bucket ?? defaultBucket).appendingPathComponent(file.path) else {
            throw S3.Error.invalidUrl
        }
        return url
    }
    
}
