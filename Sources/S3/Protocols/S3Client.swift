//
//  S3Signer.swift
//  S3
//
//  Created by Ondrej Rafaj on 18/04/2018.
//

import Foundation
import Vapor


/// S3 client Protocol
public protocol S3Client {
    
    /// Get list of objects
    func buckets(on eventLoop: EventLoop) -> EventLoopFuture<BucketsInfo>
    
    /// Create a bucket
    func create(bucket: String, region: Region?, on eventLoop: EventLoop) -> EventLoopFuture<Void>
    
    /// Delete a bucket wherever it is
//    func delete(bucket: String, on container: Container) -> EventLoopFuture<Void>
    
    /// Delete a bucket
    func delete(bucket: String, region: Region?, on eventLoop: EventLoop) -> EventLoopFuture<Void>
    
    /// Get bucket location
    func location(bucket: String, on eventLoop: EventLoop) -> EventLoopFuture<Region>
    
    /// Get list of objects
    func list(bucket: String, region: Region?, on eventLoop: EventLoop) -> EventLoopFuture<BucketResults>
    
    /// Get list of objects
    func list(bucket: String, region: Region?, headers: [String: String], on eventLoop: EventLoop) -> EventLoopFuture<BucketResults>
    
    /// Upload file to S3
    func put(file: File.Upload, on eventLoop: EventLoop) -> EventLoopFuture<File.Response>
    
    /// Upload file to S3
    func put(file: File.Upload, headers: [String: String], on eventLoop: EventLoop) -> EventLoopFuture<File.Response>
    
    /// Upload file to S3
    func put(file url: URL, destination: String, access: AccessControlList, on eventLoop: EventLoop) -> EventLoopFuture<File.Response>
    
    /// Upload file to S3
    func put(file url: URL, destination: String, bucket: String?, access: AccessControlList, on eventLoop: EventLoop) -> EventLoopFuture<File.Response>
    
    /// Upload file to S3
    func put(file path: String, destination: String, access: AccessControlList, on eventLoop: EventLoop) -> EventLoopFuture<File.Response>
    
    /// Upload file to S3
    func put(file path: String, destination: String, bucket: String?, access: AccessControlList, on eventLoop: EventLoop) -> EventLoopFuture<File.Response>
    
    /// Upload file to S3
    func put(string: String, destination: String, on eventLoop: EventLoop) -> EventLoopFuture<File.Response>
    
    /// Upload file to S3
    func put(string: String, destination: String, access: AccessControlList, on eventLoop: EventLoop) -> EventLoopFuture<File.Response>
    
    /// Upload file to S3
    func put(string: String, mime: HTTPMediaType, destination: String, on eventLoop: EventLoop) -> EventLoopFuture<File.Response>
    
    /// Upload file to S3
    func put(string: String, mime: HTTPMediaType, destination: String, access: AccessControlList, on eventLoop: EventLoop) -> EventLoopFuture<File.Response>
    
    /// Upload file to S3
    func put(string: String, mime: HTTPMediaType, destination: String, bucket: String?, access: AccessControlList, on eventLoop: EventLoop) -> EventLoopFuture<File.Response>
    
    /// File URL
    func url(fileInfo file: LocationConvertible) throws -> URL
    
    /// Retrieve file data from S3
    func get(fileInfo file: LocationConvertible, on eventLoop: EventLoop) -> EventLoopFuture<File.Info>
    
    /// Retrieve file data from S3
    func get(fileInfo file: LocationConvertible, headers: [String: String], on eventLoop: EventLoop) -> EventLoopFuture<File.Info>
    
    /// Retrieve file data from S3
    func get(file: LocationConvertible, on eventLoop: EventLoop) -> EventLoopFuture<File.Response>
    
    /// Retrieve file data from S3
    func get(file: LocationConvertible, headers: [String: String], on eventLoop: EventLoop) -> EventLoopFuture<File.Response>
    
    /// Delete file from S3
    func delete(file: LocationConvertible, on eventLoop: EventLoop) -> EventLoopFuture<Void>
    
    /// Delete file from S3
    func delete(file: LocationConvertible, headers: [String: String], on eventLoop: EventLoop) -> EventLoopFuture<Void>
    
    /// Copy file on S3
    func copy(file: LocationConvertible, to: LocationConvertible, headers: [String: String], on eventLoop: EventLoop) -> EventLoopFuture<File.CopyResponse>
}

extension S3Client {
    
    /// Copy file on S3
    public func copy(file: LocationConvertible, to: LocationConvertible, on eventLoop: EventLoop) -> EventLoopFuture<File.CopyResponse> {
        return self.copy(file: file, to: to, headers: [:], on: eventLoop)
    }
    
}
