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
    
    /// Error messages
    public enum Error: Swift.Error {
        case invalidUrl
        case errorResponse(HTTPResponseStatus, ErrorMessage)
        case badResponse(Response)
        case badStringData
        case missingData
        case notFound
        case s3NotRegistered
    }
    
    /// If set, this bucket name value will be used globally unless overriden by a specific call
    public internal(set) var defaultBucket: String
    
    /// Signer instance
    public let signer: S3Signer
    
    let urlBuilder: URLBuilder?
    
    // MARK: Initialization
    
    /// Basic initialization method, also registers S3Signer and self with services
    @discardableResult public convenience init(defaultBucket: String, config: S3Signer.Config, services: inout Services) throws {
        let signer = try S3Signer(config)
        try self.init(defaultBucket: defaultBucket, signer: signer)
        
        services.register(signer)
        services.register(self, as: S3Client.self)
    }
    
    /// Basic initialization method
    public init(defaultBucket: String, signer: S3Signer) throws {
        self.defaultBucket = defaultBucket
        self.signer = signer
        self.urlBuilder = nil
    }
    
    /// Basic initialization method
    public init(urlBuilder: URLBuilder, defaultBucket: String, signer: S3Signer) throws {
        self.defaultBucket = defaultBucket
        self.signer = signer
        self.urlBuilder = nil
    }
    
}

// MARK: - Helper methods

extension S3 {
    
    // QUESTION: Can we replace this with just Data()?
    /// Serve empty data
    func emptyData() -> Data {
        return "".convertToData()
    }
    
    /// Check response for error
    @discardableResult func check(_ response: Response) throws -> Response {
        guard response.http.status == .ok || response.http.status == .noContent else {
            if let error = try? response.decode(to: ErrorMessage.self) {
                throw Error.errorResponse(response.http.status, error)
            } else {
                throw Error.badResponse(response)
            }
        }
        return response
    }
    
    /// Get mime type for file
    static func mimeType(forFileAtUrl url: URL) -> String {
        guard let mediaType = MediaType.fileExtension(url.pathExtension) else {
            return MediaType(type: "application", subType: "octet-stream").description
        }
        return mediaType.description
    }
    
    /// Get mime type for file
    func mimeType(forFileAtUrl url: URL) -> String {
        return S3.mimeType(forFileAtUrl: url)
    }
    
    /// Create URL builder
    func urlBuilder(for container: Container) -> URLBuilder {
        return urlBuilder ?? S3URLBuilder(container, defaultBucket: defaultBucket, config: signer.config)
    }
    
}
