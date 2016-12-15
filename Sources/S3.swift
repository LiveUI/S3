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
import MimeLib

/**
 Available access control list values for "x-amz-acl" header as specified in AWS documentation
 */
public enum AccessControlList: String {
    case privateAccess = "private"
    case publicRead = "public-read"
    case publicReadWrite = "public-read-write"
    case awsExecRead = "aws-exec-read"
    case authenticatedRead = "authenticated-read"
    case bucketOwnerRead = "bucket-owner-read"
    case bucketOwnerFullControl = "bucket-owner-full-control"
}

/**
 Error messages
 */
public enum Error: Swift.Error {
    case missingCredentials(String)
    case invalidUrl
    case badResponse(Response)
    case missingBucketName
    case badStringData
    case missingData
}


// MARK: - S3

/**
 Main S3 class
 */
public class S3 {
    
    /**
     If set, this bucket name value will be used globally unless overriden by a specific call
     */
    public var bucketName: String?
    
    /**
     S3 Signer class (https://github.com/JustinM1/S3SignerAWS)
     */
    let signer: S3SignerAWS
    
    /**
     Private copy of a droplet variable from main.swift, needs to be passed during initialization
     */
    private let drop: Droplet
    
    
    // MARK: Initialization
    
    /**
     Basic initialization method, uses Config/s3.json to configure connections
     
     - Parameters:
     - droplet: Droplet variable from main.swift
     */
    public convenience init(droplet drop: Droplet, bucketName: String? = nil) throws {
        guard let accessKey: String = drop.config["s3", "accessKey"]?.string else {
            throw Error.missingCredentials("accessKey")
        }
        
        guard let secretKey: String = drop.config["s3", "secretKey"]?.string else {
            throw Error.missingCredentials("secretKey")
        }
        
        self.init(droplet: drop, accessKey: accessKey, secretKey: secretKey)
        
        self.bucketName = bucketName
    }
    
    /**
     Initialization method with custom connection and bucket config
     
     - Parameters:
     - droplet: Droplet variable from main.swift
     - accessKey: AWS Access key
     - secretKey: AWS Secret key
     - bucketName: Name of the global bucket to be used for calls where bucket is not specified (optional)
     - region: AWS Region, default is .usEast1_Virginia
     */
    public init(droplet drop: Droplet, accessKey: String, secretKey: String, bucketName: String?, region: Region = .usEast1_Virginia) {
        self.drop = drop
        self.bucketName = bucketName
        self.signer = S3SignerAWS(accessKey: accessKey, secretKey: secretKey, region: region)
    }
    
    /**
     Initialization method with custom connection config
     
     - Parameters:
     - droplet: Droplet variable from main.swift
     - accessKey: AWS Access key
     - secretKey: AWS Secret key
     - region: AWS Region, default is .usEast1_Virginia
     */
    public convenience init(droplet drop: Droplet, accessKey: String, secretKey: String, region: Region = .usEast1_Virginia) {
        self.init(droplet: drop, accessKey: accessKey, secretKey: secretKey, bucketName: nil, region: region)
    }
    
    // MARK: Managing objects
    
    /**
     Upload file to S3, full set
     
     - Parameters:
     - data: File data
     - filePath: Path to a file within the bucket (image.jpg)
     - bucketName: Name of the bucket to be used (global bucket value will be ignored)
     - headers: Additional headers to be passed with the request
     - accessControl: Access control list value (default .privateAccess)
     */
    public func put(data: Data, filePath: String, bucketName: String, headers: [String: String], accessControl: AccessControlList = .privateAccess) throws {
        let fileUrl: URL? = try self.buildUrl(bucketName: bucketName, fileName: filePath)
        guard let url = fileUrl else {
            throw Error.invalidUrl
        }
        
        let bytes: Bytes = try data.makeBytes()
        var awsHeaders: [String: String] = headers
        awsHeaders["x-amz-acl"] = accessControl.rawValue
        let signingHeaders: [String: String] = try signer.authHeaderV4(httpMethod: .put, urlString: url.absoluteString, headers: awsHeaders, payload: .bytes(bytes))
        let result: Response = try self.drop.client.put(fileUrl!.absoluteString, headers: self.vaporHeaders(signingHeaders), query: [:], body: Body(bytes))
        
        guard result.status == .ok else {
            throw Error.badResponse(result)
        }
    }
    
    /**
     Upload file to S3, no headers
     
     - Parameters:
     - data: File data
     - filePath: Path to a file within the bucket (image.jpg)
     - bucketName: Name of the bucket to be used (global bucket value will be ignored)
     - accessControl: Access control list value (default .privateAccess)
     */
    public func put(data: Data, filePath: String, bucketName: String, accessControl: AccessControlList = .privateAccess) throws {
        try self.put(data: data, filePath: filePath, bucketName: bucketName, headers: [:], accessControl: accessControl)
    }
    
    /**
     Upload file to S3, with content type (mime)
     
     - Parameters:
     - data: File data
     - filePath: Path to a file within the bucket (image.jpg)
     - bucketName: Name of the bucket to be used (global bucket value will be ignored)
     - contentType: Mime type of the uploaded file (Example: image/png)
     - accessControl: Access control list value (default .privateAccess)
     */
    public func put(data: Data, filePath: String, bucketName: String, contentType: String, accessControl: AccessControlList = .privateAccess) throws {
        try self.put(data: data, filePath: filePath, bucketName: bucketName, headers: ["Content-Type": contentType], accessControl: accessControl)
    }
    
    /**
     Upload file to S3, basic settings
     
     - Parameters:
     - data: File data
     - filePath: Path to a file within the bucket (image.jpg)
     - accessControl: Access control list value (default .privateAccess)
     */
    public func put(data: Data, filePath: String, accessControl: AccessControlList = .privateAccess) throws {
        guard let bucketName = self.bucketName else {
            throw Error.missingBucketName
        }
        try self.put(data: data, filePath: filePath, bucketName: bucketName, accessControl: accessControl)
    }
    
    /**
     Retrieve file data from S3
     
     - Parameters:
     - fileAtPath: Path to a file within the bucket (images/image.jpg)
     - bucketName: Name of the bucket to be used (global bucket value will be ignored, optional)
     
     - Returns: File data
     */
    public func get(fileAtPath filePath: String, bucketName: String? = nil) throws -> Data {
        let fileUrl: URL? = try self.buildUrl(bucketName: bucketName, fileName: filePath)
        guard let url = fileUrl else {
            throw Error.invalidUrl
        }
        
        let headers: [String: String] = try signer.authHeaderV4(httpMethod: .get, urlString: url.absoluteString, headers: [:], payload: .none)
        let result: Response = try self.drop.client.get(fileUrl!.absoluteString, headers: self.vaporHeaders(headers))
        guard result.status == .ok else {
            throw Error.badResponse(result)
        }
        
        guard let bytes: Bytes = result.body.bytes else {
            throw Error.missingData
        }
        let data: Data = Data.init(bytes: bytes)
        
        return data
    }
    
    /**
     Delete file from S3
     
     - Parameters:
     - fileAtPath: Path to a file within the bucket (images/image.jpg)
     - bucketName: Name of the bucket to be used (global bucket value will be ignored, optional)
     */
    public func delete(fileAtPath filePath: String, bucketName: String? = nil) throws {
        let fileUrl: URL? = try self.buildUrl(bucketName: bucketName, fileName: filePath)
        guard let url = fileUrl else {
            throw Error.invalidUrl
        }
        
        let headers: [String: String] = try signer.authHeaderV4(httpMethod: .delete, urlString: url.absoluteString, headers: [:], payload: .none)
        
        let result: Response = try self.drop.client.delete(fileUrl!.absoluteString, headers: self.vaporHeaders(headers), query: [:], body: Body(""))
        
        guard result.status == .noContent || result.status == .ok else {
            throw Error.badResponse(result)
        }
    }
    
}

// MARK: - Helper methods

internal extension S3 {
    
    internal func mimeType(forFileAtUrl url: URL) -> String {
        guard let mime: String = Mime.string(forUrl: url) else {
            return "application/octet-stream"
        }
        return mime
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
            throw Error.missingBucketName
        }
        
        var url: URL = URL(string: "https://s3.amazonaws.com")!
        url.appendPathComponent(bucket!)
        url.appendPathComponent(fileName)
        return url
    }
    
}
