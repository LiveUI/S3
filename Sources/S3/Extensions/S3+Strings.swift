//
//  S3+Strings.swift
//  S3
//
//  Created by Ondrej Rafaj on 01/12/2016.
//  Copyright © 2016 manGoweb UK Ltd. All rights reserved.
//

import Foundation
import Vapor


extension S3 {
    
    /// Upload file content to S3, full set
    public func put(string: String, mime: MediaType, destination: String, bucket: String?, access: AccessControlList, on container: Container) throws -> Future<File.Response> {
        guard let data: Data = string.data(using: String.Encoding.utf8) else {
            throw Error.badStringData
        }
        let file = File.Upload(data: data, bucket: bucket, destination: destination, access: access, mime: mime.description)
        return try put(file: file, on: container)
    }
    
    /// Upload file content to S3
    public func put(string: String, mime: MediaType, destination: String, access: AccessControlList, on container: Container) throws -> Future<File.Response> {
        return try put(string: string, mime: mime, destination: destination, bucket: nil, access: access, on: container)
    }
    
    /// Upload file content to S3
    public func put(string: String, destination: String, access: AccessControlList, on container: Container) throws -> Future<File.Response> {
        return try put(string: string, mime: .plainText, destination: destination, bucket: nil, access: access, on: container)
    }
    
    /// Upload file content to S3
    public func put(string: String, mime: MediaType, destination: String, on container: Container) throws -> Future<File.Response> {
        return try put(string: string, mime: mime, destination: destination, access: .privateAccess, on: container)
    }
    
    /// Upload file content to S3
    public func put(string: String, destination: String, on container: Container) throws -> Future<File.Response> {
        return try put(string: string, mime: .plainText, destination: destination, bucket: nil, access: .privateAccess, on: container)
    }
    
}
