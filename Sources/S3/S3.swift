//
//  S3.swift
//  S3
//
//  Created by Ondrej Rafaj on 01/12/2016.
//  Copyright © 2016 manGoweb UK Ltd. All rights reserved.
//

import Foundation
import Vapor
@_exported import S3Signer
import HTTP


/// Main S3 class
public class S3: S3Client {
    
    /// Available access control list values for "x-amz-acl" header as specified in AWS documentation
    public enum AccessControlList: String {
        case privateAccess = "private"
        case publicRead = "public-read"
        case publicReadWrite = "public-read-write"
        case awsExecRead = "aws-exec-read"
        case authenticatedRead = "authenticated-read"
        case bucketOwnerRead = "bucket-owner-read"
        case bucketOwnerFullControl = "bucket-owner-full-control"
    }
    
    
    public struct File {
        
        /// File to be uploaded (PUT)
        public struct Upload: FileInfo {
            
            /// Data
            public internal(set) var data: Data
            
            /// Override target bucket
            public internal(set) var bucket: String?
            
            /// S3 file path
            public internal(set) var path: String
            
            /// Desired access control for file
            public internal(set) var access: AccessControlList = .privateAccess
            
            /// Desired file type (mime) for the uploaded file
            public internal(set) var mime: MediaType = .plainText
            
            // MARK: Initialization
            
            /// File data to be uploaded
            public init(data: Data, bucket: String? = nil, destination: String, access: AccessControlList = .privateAccess, mime: MediaType = .plainText) {
                self.data = data
                self.bucket = bucket
                self.path = destination
                self.access = access
                self.mime = mime
            }
            
            /// File to be uploaded
            public init(file: URL, bucket: String? = nil, destination: String, access: AccessControlList = .privateAccess) throws {
                self.data = try Data(contentsOf: file)
                self.bucket = bucket
                self.path = destination
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
        public struct Location: FileInfo {
            
            /// Override target bucket
            public internal(set) var bucket: String?
            
            /// S3 file path
            public internal(set) var path: String
            
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
        case missingCredentials(String)
        case invalidUrl
        case badResponse(Response)
        case badStringData
        case missingData
        case notFound
        
        case uploadFailed(Response)
    }
    
    /// If set, this bucket name value will be used globally unless overriden by a specific call
    public internal(set) var defaultBucket: String
    
    
    // MARK: Initialization
    
    /// Basic initialization method, also registers S3Signer and self with services
    @discardableResult public convenience init(defaultBucket: String, config: S3Signer.Config, services: inout Services) throws {
        try self.init(defaultBucket: defaultBucket)
        
        try services.register(S3Signer(config))
        services.register(self)
    }
    
    /// Basic initialization method
    public init(defaultBucket: String) throws {
        self.defaultBucket = defaultBucket
    }
    
    // MARK: Managing objects
    
    /// Upload file to S3
    public func put(file: File.Upload, headers: [String: String] = [:], on req: Request) throws -> EventLoopFuture<File.Response> {
        guard let url = try buildUrl(file: file, on: req) else {
            throw Error.invalidUrl
        }
        
        var awsHeaders: [String: String] = headers
        awsHeaders["Content-Type"] = file.mime.description
        awsHeaders["x-amz-acl"] = file.access.rawValue
        let signer = try req.make(S3Signer.self)
        let headers = try signer.headers(for: .PUT, urlString: url.absoluteString, headers: awsHeaders, payload: .bytes(file.data))
        
        return try make(request: url, method: .PUT, headers: headers, data: file.data, on: req).map(to: File.Response.self) { response in
            if response.http.status == .ok {
                let res = File.Response(data: file.data, bucket: file.bucket ?? self.defaultBucket, path: file.path, access: file.access, mime: file.mime)
                return res
            } else {
                throw Error.uploadFailed(response)
            }
        }
    }
    
    
    
    /// Retrieve file data from S3
    public func get(file: File.Location, headers: [String: String] = [:], on req: Request) throws -> Future<File.Response> {
        guard let url = try buildUrl(file: file, on: req) else {
            throw Error.invalidUrl
        }
        
        let awsHeaders: [String: String] = headers
        let signer = try req.make(S3Signer.self)
        let headers = try signer.headers(for: .GET, urlString: url.absoluteString, headers: awsHeaders, payload: .none)
        
        return try make(request: url, method: .GET, headers: headers, on: req).map(to: File.Response.self) { response in
            if response.http.status == .notFound {
                throw Error.notFound
            }
            guard response.http.status == .ok else {
                throw Error.badResponse(response)
            }
            guard let data = response.http.body.data else {
                throw Error.missingData
            }
            
            let res = File.Response(data: data, bucket: file.bucket ?? self.defaultBucket, path: file.path, access: nil, mime: self.mimeType(forFileAtUrl: url))
            return res
        }
    }
    
    
    /// Delete file from S3
    public func delete(file: File.Location, headers: [String: String] = [:], on req: Request) throws -> Future<Void> {
        guard let url = try buildUrl(file: file, on: req) else {
            throw Error.invalidUrl
        }
        
        let awsHeaders: [String: String] = headers
        let signer = try req.make(S3Signer.self)
        let headers = try signer.headers(for: .GET, urlString: url.absoluteString, headers: awsHeaders, payload: .none)
        
        return try make(request: url, method: .DELETE, headers: headers, on: req).map(to: Void.self) { response in
            if response.http.status == .notFound {
                throw Error.notFound
            }
            guard response.http.status == .ok || response.http.status == .noContent else {
                throw Error.badResponse(response)
            }
            return Void()
        }
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
    
    func buildUrl(file: FileInfo, on req: Request) throws -> URL? {
        let config = try req.makeS3Signer().config
        
        guard var url: URL = URL(string: config.region.host) else {
            throw Error.invalidUrl
        }
        url.appendPathComponent(file.bucket ?? defaultBucket)
        url.appendPathComponent(file.path)
        return url
    }
    
}
