//
//  S3Signer.swift
//  S3
//
//  Created by Ondrej Rafaj on 18/04/2018.
//

import Foundation
import Vapor


public protocol S3Client: Service {
    func buckets(on: Container) throws -> Future<BucketsInfo>
    func create(bucket: String, region: Region?, on container: Container) throws -> Future<Void>
    func delete(bucket: String, region: Region?, on container: Container) throws -> Future<Void>
//    func location(bucket: String, on container: Container) throws -> Future<Bucket.Location>
    
    func put(file: S3.File.Upload, headers: [String: String], on: Container) throws -> EventLoopFuture<S3.File.Response>
    
    func put(file url: URL, destination: String, access: S3.AccessControlList, on: Container) throws -> Future<S3.File.Response>
    func put(file url: URL, destination: String, bucket: String?, access: S3.AccessControlList, on: Container) throws -> Future<S3.File.Response>
    
    func put(file path: String, destination: String, access: S3.AccessControlList, on: Container) throws -> Future<S3.File.Response>
    func put(file path: String, destination: String, bucket: String?, access: S3.AccessControlList, on: Container) throws -> Future<S3.File.Response>
    
    func put(string: String, destination: String, on: Container) throws -> Future<S3.File.Response>
    func put(string: String, destination: String, access: S3.AccessControlList, on: Container) throws -> Future<S3.File.Response>
    func put(string: String, mime: MediaType, destination: String, on: Container) throws -> Future<S3.File.Response>
    func put(string: String, mime: MediaType, destination: String, access: S3.AccessControlList, on: Container) throws -> Future<S3.File.Response>
    func put(string: String, mime: MediaType, destination: String, bucket: String?, access: S3.AccessControlList, on: Container) throws -> Future<S3.File.Response>
    
    func get(file: LocationConvertible, on: Container) throws -> Future<S3.File.Response>
    func get(file: LocationConvertible, headers: [String: String], on: Container) throws -> Future<S3.File.Response>
    
    func delete(file: LocationConvertible, on: Container) throws -> Future<Void>
    func delete(file: LocationConvertible, headers: [String: String], on: Container) throws -> Future<Void>
}
