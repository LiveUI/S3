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
    
    // MARK: Managing objects
    
    /// Upload file to S3
    public func put(file: File.Upload, headers: [String: String] = [:], on container: Container) throws -> EventLoopFuture<File.Response> {
        let signer = try container.makeS3Signer()
        
        let url = try buildUrl(file: file, on: container)
        
        var awsHeaders: [String: String] = headers
//        awsHeaders["Content-Type"] = file.mime.description
        awsHeaders["X-Amz-Acl"] = file.access.rawValue
        
        let headers = try signer.headers(for: .PUT, urlString: url.absoluteString, headers: awsHeaders, payload: Payload.bytes(file.data))
        
        let request = Request(using: container)
        request.http.method = .PUT
        request.http.headers = headers
        request.http.body = HTTPBody(data: file.data)
        request.http.url = url
        let client = try container.make(Client.self)
        return client.send(request).map(to: File.Response.self) { response in
            if response.http.status == .ok {
                let res = File.Response(data: file.data, bucket: file.s3bucket ?? self.defaultBucket, path: file.s3path, access: file.access, mime: file.mime)
                return res
            } else {
                throw Error.uploadFailed(response)
            }
        }
    }
    
    /// Retrieve file data from S3
    public func get(file: LocationConvertible, headers: [String: String] = [:], on container: Container) throws -> Future<File.Response> {
        let signer = try container.makeS3Signer()
        
        let url = try buildUrl(file: file, on: container)
        
        let headers = try signer.headers(for: .GET, urlString: url.absoluteString, headers: headers, payload: .none)
        
        return try make(request: url, method: .GET, headers: headers, on: container).map(to: File.Response.self) { response in
            if response.http.status == .notFound {
                throw Error.notFound
            }
            guard response.http.status == .ok else {
                throw Error.badResponse(response)
            }
            guard let data = response.http.body.data else {
                throw Error.missingData
            }
            
            let res = File.Response(data: data, bucket: file.s3bucket ?? self.defaultBucket, path: file.s3path, access: nil, mime: self.mimeType(forFileAtUrl: url))
            return res
        }
    }
    
    /// Retrieve file data from S3
    public func get(file: LocationConvertible, on container: Container) throws -> EventLoopFuture<S3.File.Response> {
        return try get(file: file, headers: [:], on: container)
    }
    
    /// Delete file from S3
    public func delete(file: LocationConvertible, headers: [String: String] = [:], on container: Container) throws -> Future<Void> {
        let signer = try container.makeS3Signer()
        
        let url = try buildUrl(file: file, on: container)
        
        let headers = try signer.headers(for: .DELETE, urlString: url.absoluteString, headers: headers, payload: .none)
        
        return try make(request: url, method: .DELETE, headers: headers, on: container).map(to: Void.self) { response in
            if response.http.status == .notFound {
                throw Error.notFound
            }
            guard response.http.status == .ok || response.http.status == .noContent else {
                throw Error.badResponse(response)
            }
            return Void()
        }
    }
    
    /// Delete file from S3
    public func delete(file: LocationConvertible, on container: Container) throws -> Future<Void> {
        return try delete(file: file, headers: [:], on: container)
    }
    
}

// MARK: - Helper methods

extension S3 {
    
    static func mimeType(forFileAtUrl url: URL) -> MediaType {
        guard let mediaType = MediaType.fileExtension(url.pathExtension) else {
            return MediaType(type: "application", subType: "octet-stream")
        }
        return mediaType
    }
    
    func mimeType(forFileAtUrl url: URL) -> MediaType {
        return S3.mimeType(forFileAtUrl: url)
    }
    
    func buildUrl(file: LocationConvertible, on container: Container) throws -> URL {
        let signer = try container.makeS3Signer()
        let bucket = file.s3bucket ?? defaultBucket
        guard let url = URL(string: "https://" + signer.config.region.host + bucket.finished(with: "/") + file.s3path) else {
            throw Error.invalidUrl
        }
        return url
    }
    
}
