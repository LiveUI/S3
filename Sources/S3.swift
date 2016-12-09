//
//  S3.swift
//  S3
//
//  Created by Ondrej Rafaj on 01/12/2016.
//  Copyright © 2016 manGoweb UK Ltd. All rights reserved.
//

import Foundation
import Vapor
import S3SignerAWS
import HTTP


public enum AccessControlList: String {
    case privateAccess = "private"
    case publicRead = "public-read"
    case publicReadWrite = "public-read-write"
    case awsExecRead = "aws-exec-read"
    case authenticatedRead = "authenticated-read"
    case bucketOwnerRead = "bucket-owner-read"
    case bucketOwnerFullControl = "bucket-owner-full-control"
}

public enum S3Error: Swift.Error {
    case missingCredentials(String)
    case invalidUrl
    case badResponse(Response)
    case missingBucketName
    case badStringData
    case missingData
}


public struct Bucket {
    
}


public struct File {
    
}


// MARK: - Main

public class S3 {
    
    public let bucketName: String?
    
    let signer: S3SignerAWS
    
    
    // MARK: Initialization
    
    public convenience init() throws {
        guard let accessKey: String = drop.config["s3", "accessKey"]?.string else {
            throw S3Error.missingCredentials("accessKey")
        }
        
        guard let secretKey: String = drop.config["s3", "secretKey"]?.string else {
            throw S3Error.missingCredentials("secretKey")
        }
        
        self.init(accessKey: accessKey, secretKey: secretKey)
    }
    
    public init(accessKey: String, secretKey: String, bucketName: String?, region: Region) {
        self.bucketName = bucketName
        self.signer = S3SignerAWS(accessKey: accessKey, secretKey: secretKey, region: region)
    }
    
    convenience init(accessKey: String, secretKey: String, region: Region = .usEast1_Virginia) {
        self.init(accessKey: accessKey, secretKey: secretKey, bucketName: nil, region: region)
    }
    
    // MARK: Managing objects
    
    public func put(data: Data, filePath: String, bucketName: String, headers: [String: String], accessControl: AccessControlList = .privateAccess) throws {
        let fileUrl: URL? = try self.buildUrl(bucketName: bucketName, fileName: filePath)
        guard let url = fileUrl else {
            throw S3Error.invalidUrl
        }
        
        let bytes: Bytes = try data.makeBytes()
        var awsHeaders: [String: String] = headers
        awsHeaders["x-amz-acl"] = accessControl.rawValue
        let signingHeaders: [String: String] = try signer.authHeaderV4(httpMethod: .put, urlString: url.absoluteString, headers: awsHeaders, payload: .bytes(bytes))
        let result: Response = try drop.client.put(fileUrl!.absoluteString, headers: self.vaporHeaders(signingHeaders), query: [:], body: Body(bytes))
        
        guard result.status == .ok else {
            throw S3Error.badResponse(result)
        }
    }
    
    public func put(data: Data, filePath: String, bucketName: String, accessControl: AccessControlList = .privateAccess) throws {
        try self.put(data: data, filePath: filePath, bucketName: bucketName, headers: [:], accessControl: accessControl)
    }
    
    public func put(data: Data, filePath: String, accessControl: AccessControlList = .privateAccess) throws {
        guard let bucketName = self.bucketName else {
            throw S3Error.missingBucketName
        }
        try self.put(data: data, filePath: filePath, bucketName: bucketName, accessControl: accessControl)
    }
    
    public func get(infoForFilePath filePath: String, bucketName: String? = nil) throws -> [String: String]? {
        return nil
    }
    
    public func get(fileAtPath filePath: String, bucketName: String? = nil) throws -> Data {
        let fileUrl: URL? = try self.buildUrl(bucketName: bucketName, fileName: filePath)
        guard let url = fileUrl else {
            throw S3Error.invalidUrl
        }
        
        let headers: [String: String] = try signer.authHeaderV4(httpMethod: .get, urlString: url.absoluteString, headers: [:], payload: .none)
        let result: Response = try drop.client.get(fileUrl!.absoluteString, headers: self.vaporHeaders(headers))
        guard result.status == .ok else {
            throw S3Error.badResponse(result)
        }
        
        guard let bytes: Bytes = result.body.bytes else {
            throw S3Error.missingData
        }
        let data: Data = Data.init(bytes: bytes)
        
        return data
    }
    
    public func copy(fileAtPath filePath: String, sourceBucketName: String, destinationFilePath: String, targetBucketName: String, targetAccessControl: AccessControlList = .privateAccess) throws {
        
    }
    
    public func copy(fileAtPath filePath: String, sourceBucketName: String, destinationFilePath: String, targetAccessControl: AccessControlList = .privateAccess) throws {
        
    }
    
    public func copy(fileAtPath filePath: String, destinationFilePath: String, targetAccessControl: AccessControlList = .privateAccess) throws {
        
    }
    
    public func delete(fileAtPath filePath: String, bucketName: String? = nil) throws {
        let fileUrl: URL? = try self.buildUrl(bucketName: bucketName, fileName: filePath)
        guard let url = fileUrl else {
            throw S3Error.invalidUrl
        }
        
        let headers: [String: String] = try signer.authHeaderV4(httpMethod: .delete, urlString: url.absoluteString, headers: [:], payload: .none)
        
        let result: Response = try drop.client.delete(fileUrl!.absoluteString, headers: self.vaporHeaders(headers), query: [:], body: Body(""))
        
        guard result.status == .noContent || result.status == .ok else {
            throw S3Error.badResponse(result)
        }
    }
    
    // MARK: Buckets handling
    
    public func getBuckets(simple: Bool = true) throws -> [Bucket]? {
        return nil
    }
    
    public func createBucket(bucketName: String) throws {
        
    }
    
    public func get(contentOfBucket: String? = nil) throws -> [File]? {
        return nil
    }
    
    public func deleteBucket(bucketName: String? = nil) throws {
        
    }
    
}

// MARK: - Helper methods

internal extension S3 {
    
    internal func mimeType(forFileAtUrl url: URL) -> String {
        let pathExtension: String = url.pathExtension
        
        if let uti = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, pathExtension as NSString, nil)?.takeRetainedValue() {
            if let mimetype = UTTypeCopyPreferredTagWithClass(uti, kUTTagClassMIMEType)?.takeRetainedValue() {
                return mimetype as String
            }
        }
        return "application/octet-stream"
    }
    
    internal func vaporHeaders(_ headers: [String: String]) -> [HeaderKey : String] {
        var vaporHeaders: [HeaderKey : String] = [:]
        for header in headers {
            let hk = HeaderKey(header.key)
            vaporHeaders[hk] = header.value
        }
        return vaporHeaders
    }
    
    internal func buildUrl(bucketName: String?, fileName: String) throws -> URL? {
        var bucket: String? = bucketName
        if bucket == nil {
            bucket = self.bucketName
        }
        guard bucket != nil else {
            throw S3Error.missingBucketName
        }
        
        var url: URL = URL(string: "https://s3.amazonaws.com")!
        url.appendPathComponent(bucket!)
        url.appendPathComponent(fileName)
        return url
    }
    
}

