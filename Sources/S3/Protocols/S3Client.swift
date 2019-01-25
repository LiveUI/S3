//
//  S3Signer.swift
//  S3
//
//  Created by Ondrej Rafaj on 18/04/2018.
//

import Foundation
import Vapor


/// S3 client Protocol
public protocol S3Client: Service {
    
    /// Get list of objects
    func buckets(on: Container) throws -> Future<BucketsInfo>
    
    /// Create a bucket
    func create(bucket: String, region: Region?, on container: Container) throws -> Future<Void>
    
    /// Delete a bucket wherever it is
//    func delete(bucket: String, on container: Container) throws -> Future<Void>
    
    /// Delete a bucket
    func delete(bucket: String, region: Region?, on container: Container) throws -> Future<Void>
    
    /// Get bucket location
    func location(bucket: String, on container: Container) throws -> Future<Region>
    
    /// Get list of objects
    func list(bucket: String, region: Region?, on container: Container) throws -> Future<BucketResults>

    /// Get list of objects
    func list(bucket: String, region: Region?, prefix: String?, delimiter: String?, on container: Container) throws -> Future<BucketResults>

    /// Get list of objects
    func list(bucket: String, region: Region?, headers: [String: String], prefix: String?, delimiter: String?, on container: Container) throws -> Future<BucketResults>
    
    /// Upload file to S3
    func put(file: File.Upload, on container: Container) throws -> EventLoopFuture<File.Response>
    
    /// Upload file to S3
    func put(file: File.Upload, headers: [String: String], on: Container) throws -> EventLoopFuture<File.Response>
    
    /// Upload file to S3
    func put(file url: URL, destination: String, access: AccessControlList, on: Container) throws -> Future<File.Response>
    
    /// Upload file to S3
    func put(file url: URL, destination: String, bucket: String?, access: AccessControlList, on: Container) throws -> Future<File.Response>
    
    /// Upload file to S3
    func put(file path: String, destination: String, access: AccessControlList, on: Container) throws -> Future<File.Response>
    
    /// Upload file to S3
    func put(file path: String, destination: String, bucket: String?, access: AccessControlList, on: Container) throws -> Future<File.Response>
    
    /// Upload file to S3
    func put(string: String, destination: String, on: Container) throws -> Future<File.Response>
    
    /// Upload file to S3
    func put(string: String, destination: String, access: AccessControlList, on: Container) throws -> Future<File.Response>
    
    /// Upload file to S3
    func put(string: String, mime: MediaType, destination: String, on: Container) throws -> Future<File.Response>
    
    /// Upload file to S3
    func put(string: String, mime: MediaType, destination: String, access: AccessControlList, on: Container) throws -> Future<File.Response>
    
    /// Upload file to S3
    func put(string: String, mime: MediaType, destination: String, bucket: String?, access: AccessControlList, on: Container) throws -> Future<File.Response>
    
    /// File URL
    func url(fileInfo file: LocationConvertible, on container: Container) throws -> URL
    
    /// Retrieve file data from S3
    func get(fileInfo file: LocationConvertible, on container: Container) throws -> Future<File.Info>
    
    /// Retrieve file data from S3
    func get(fileInfo file: LocationConvertible, headers: [String: String], on container: Container) throws -> Future<File.Info>
    
    /// Retrieve file data from S3
    func get(file: LocationConvertible, on: Container) throws -> Future<File.Response>
    
    /// Retrieve file data from S3
    func get(file: LocationConvertible, headers: [String: String], on: Container) throws -> Future<File.Response>
    
    /// Delete file from S3
    func delete(file: LocationConvertible, on: Container) throws -> Future<Void>
    
    /// Delete file from S3
    func delete(file: LocationConvertible, headers: [String: String], on: Container) throws -> Future<Void>
    
    /// Copy file on S3
    func copy(file: LocationConvertible, to: LocationConvertible, headers: [String: String], on: Container) throws -> Future<File.CopyResponse>
}

extension S3Client {
    
    /// Copy file on S3
    public func copy(file: LocationConvertible, to: LocationConvertible, on container: Container) throws -> Future<File.CopyResponse> {
        return try self.copy(file: file, to: to, headers: [:], on: container)
    }
    
}
