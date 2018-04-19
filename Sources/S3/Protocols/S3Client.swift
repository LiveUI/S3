//
//  S3Signer.swift
//  S3
//
//  Created by Ondrej Rafaj on 18/04/2018.
//

import Foundation
import Vapor


public protocol S3Client: Service {
    func put(file: S3.File.Upload, headers: [String: String], on req: Request) throws -> EventLoopFuture<S3.File.Response>
    func put(file url: URL, destination: String, bucket: String?, access: S3.AccessControlList, on req: Request) throws -> Future<S3.File.Response>
    func put(file path: String, destination: String, bucket: String?, access: S3.AccessControlList, on req: Request) throws -> Future<S3.File.Response>
    func put(string: String, mime: MediaType, destination: String, bucket: String?, access: S3.AccessControlList, on req: Request) throws -> Future<S3.File.Response>
    func get(file: S3.File.Location, headers: [String: String], on req: Request) throws -> Future<S3.File.Response>
    func delete(file: S3.File.Location, headers: [String: String], on req: Request) throws -> Future<Void>
}
