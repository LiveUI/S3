//
//  S3.swift
//  S3
//
//  Created by Ondrej Rafaj on 01/12/2016.
//  Copyright © 2016 manGoweb UK Ltd. All rights reserved.
//

import Foundation
import Vapor
import HTTP
@_exported import S3Signer


/// Main S3 class
public class S3: S3Client {    
    
    
    /// Available access control list values for "x-amz-acl" header as specified in AWS documentation
    public enum AccessControlList: String {
        
        /// Owner gets FULL_CONTROL. No one else has access rights (default).
        case privateAccess = "private"
        
        /// Owner gets FULL_CONTROL. The AllUsers group (see Who Is a Grantee? at https://docs.aws.amazon.com/AmazonS3/latest/dev/acl-overview.html#specifying-grantee) gets READ access.
        case publicRead = "public-read"
        
        /// Owner gets FULL_CONTROL. The AllUsers group gets READ and WRITE access. Granting this on a bucket is generally not recommended.
        case publicReadWrite = "public-read-write"
        
        /// Owner gets FULL_CONTROL. Amazon EC2 gets READ access to GET an Amazon Machine Image (AMI) bundle from Amazon S3.
        case awsExecRead = "aws-exec-read"
        
        /// Owner gets FULL_CONTROL. The AuthenticatedUsers group gets READ access.
        case authenticatedRead = "authenticated-read"
        
        /// Object owner gets FULL_CONTROL. Bucket owner gets READ access. If you specify this canned ACL when creating a bucket, Amazon S3 ignores it.
        case bucketOwnerRead = "bucket-owner-read"
        
        /// Both the object owner and the bucket owner get FULL_CONTROL over the object. If you specify this canned ACL when creating a bucket, Amazon S3 ignores it.
        case bucketOwnerFullControl = "bucket-owner-full-control"
        
        /// The LogDelivery group gets WRITE and READ_ACP permissions on the bucket. For more information about logs, see (https://docs.aws.amazon.com/AmazonS3/latest/dev/ServerLogs.html).
        case logDeliveryWrite = "log-delivery-write"
    }
    
    /// File data
    public struct File {
        
        /// File to be uploaded (PUT)
        public struct Upload: LocationConvertible {
            
            /// Data
            public internal(set) var data: Data
            
            /// Override target bucket
            public internal(set) var s3bucket: String?
            
            /// S3 file path
            public internal(set) var s3path: String
            
            /// Desired access control for file
            public internal(set) var access: AccessControlList = .privateAccess
            
            /// Desired file type (mime) for the uploaded file
            public internal(set) var mime: MediaType = .plainText
            
            // MARK: Initialization
            
            /// File data to be uploaded
            public init(data: Data, bucket: String? = nil, destination: String, access: AccessControlList = .privateAccess, mime: MediaType = .plainText) {
                self.data = data
                self.s3bucket = bucket
                self.s3path = destination
                self.access = access
                self.mime = mime
            }
            
            /// File to be uploaded
            public init(file: URL, bucket: String? = nil, destination: String, access: AccessControlList = .privateAccess) throws {
                self.data = try Data(contentsOf: file)
                self.s3bucket = bucket
                self.s3path = destination
                self.access = access
                self.mime = mimeType(forFileAtUrl: file)
            }
            
            /// File to be uploaded
            public init(file: String, bucket: String? = nil, destination: String, access: AccessControlList = .privateAccess) throws {
                guard let url = URL(string: file) else {
                    throw Error.invalidUrl
                }
                try self.init(file: url, bucket: bucket, destination: destination, access: access)
            }
            
        }
        
        /// File to be located
        public struct Location: LocationConvertible {
            
            /// Override target bucket
            public internal(set) var s3bucket: String?
            
            /// S3 file path
            public internal(set) var s3path: String
            
            /// Initializer
            public init(path: String, bucket: String? = nil) {
                self.s3path = path
                self.s3bucket = bucket
            }
            
        }
        
        /// File response comming back from S3
        public struct Response {
            
            /// Data
            public internal(set) var data: Data
            
            /// Override target bucket
            public internal(set) var bucket: String?
            
            /// S3 file path
            public internal(set) var path: String
            
            /// Access control for file
            public internal(set) var access: AccessControlList?
            
            /// File type (mime)
            public internal(set) var mime: MediaType
        
        }
    }
    
    /// Error messages
    public enum Error: Swift.Error {
        case invalidUrl
        case badResponse(Response)
        case badStringData
        case missingData
        case notFound
        case s3NotRegistered
        case uploadFailed(Response)
    }
    
    /// If set, this bucket name value will be used globally unless overriden by a specific call
    public internal(set) var defaultBucket: String
    
    
    // MARK: Initialization
    
    /// Basic initialization method, also registers S3Signer and self with services
    @discardableResult public convenience init(defaultBucket: String, config: S3Signer.Config, services: inout Services) throws {
        try self.init(defaultBucket: defaultBucket)
        
        try services.register(S3Signer(config))
        services.register(self, as: S3Client.self)
    }
    
    /// Basic initialization method
    public init(defaultBucket: String) throws {
        self.defaultBucket = defaultBucket
    }
    
}

// MARK: - Helper methods

extension S3 {
    
    /// Get mime type for file
    static func mimeType(forFileAtUrl url: URL) -> MediaType {
        guard let mediaType = MediaType.fileExtension(url.pathExtension) else {
            return MediaType(type: "application", subType: "octet-stream")
        }
        return mediaType
    }
    
    /// Get mime type for file
    func mimeType(forFileAtUrl url: URL) -> MediaType {
        return S3.mimeType(forFileAtUrl: url)
    }
    
    /// Generic bucket based host
    public func host(bucket: String) -> String {
        return "\(bucket).s3.amazonaws.com"
    }
    
    /// Base URL for S3 region
    func url(region: Region? = nil, bucket: String? = nil, on container: Container) throws -> URL {
        let signer = try container.makeS3Signer()
        let urlString = (region ?? signer.config.region).hostUrlString + (bucket?.finished(with: "/") ?? "")
        guard let url = URL(string: urlString) else {
            throw Error.invalidUrl
        }
        return url
    }
    
    /// Base URL for a file in a bucket
    func url(file: LocationConvertible, on container: Container) throws -> URL {
        let signer = try container.makeS3Signer()
        let bucket = file.s3bucket ?? defaultBucket
        guard let url = URL(string: signer.config.region.hostUrlString + bucket.finished(with: "/") + file.s3path) else {
            throw Error.invalidUrl
        }
        return url
    }
    
}
