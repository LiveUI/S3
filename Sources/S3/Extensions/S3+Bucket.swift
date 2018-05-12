//
//  S3+Bucket.swift
//  S3
//
//  Created by Ondrej Rafaj on 11/05/2018.
//

import Foundation
import Vapor
import S3Signer


// Helper S3 extension for working with buckets
public extension S3 {
    
    // MARK: Buckets
    
//    /// Get bucket location
//    public func location(bucket: String, on container: Container) throws -> Future<Bucket.Location> {
//        let signer = try container.makeS3Signer()
//
//        let region = region ?? signer.config.region
//        guard let url = URL(string: "https://\(bucket).s3.amazonaws.com/?location"), let host = url.host else {
//            throw Error.invalidUrl
//        }
//
//        let headers = [
//            "Host": host
//        ]
//        let awsHeaders = try signer.headers(for: .GET, urlString: url.absoluteString, region: region, headers: headers, payload: .none)
//
//        return try make(request: url, method: .GET, headers: awsHeaders, data: "".convertToData(), on: container).map(to: Bucket.Location.self) { response in
//            if response.http.status == .notFound {
//                throw Error.notFound
//            }
//            guard response.http.status == .ok || response.http.status == .noContent else {
//                if let error = try? response.decode(to: ErrorMessage.self) {
//                    throw Error.errorResponse(response.http.status, error)
//                } else {
//                    throw Error.badResponse(response)
//                }
//            }
//            return try response.decode(to: Bucket.Location.self)
//        }
//    }
    
    /// Delete bucket
    public func delete(bucket: String, region: Region? = nil, on container: Container) throws -> Future<Void> {
        let signer = try container.makeS3Signer()
        
        let region = region ?? signer.config.region
        guard let url = URL(string: "https://\(bucket).s3.\(region.rawValue).amazonaws.com/"), let host = url.host else {
            throw Error.invalidUrl
        }
        
        let headers = [
            "Host": host
        ]
        let awsHeaders = try signer.headers(for: .DELETE, urlString: url.absoluteString, region: region, headers: headers, payload: .none)
        
        return try make(request: url, method: .DELETE, headers: awsHeaders, data: "".convertToData(), on: container).map(to: Void.self) { response in
            if response.http.status == .notFound {
                throw Error.notFound
            }
            guard response.http.status == .ok || response.http.status == .noContent else {
                if let error = try? response.decode(to: ErrorMessage.self) {
                    throw Error.errorResponse(response.http.status, error)
                } else {
                    throw Error.badResponse(response)
                }
            }
            return Void()
        }
    }
    
    /// Create a bucket
    public func create(bucket: String, region: Region? = nil, on container: Container) throws -> Future<Void> {
        let signer = try container.makeS3Signer()
        
        let region = region ?? signer.config.region
        guard let url = URL(string: "https://\(bucket).s3.\(region.rawValue).amazonaws.com/"), let host = url.host else {
            throw Error.invalidUrl
        }
        
        let content = """
            <CreateBucketConfiguration xmlns="http://s3.amazonaws.com/doc/2006-03-01/">
                <LocationConstraint>\(region.rawValue)</LocationConstraint>
            </CreateBucketConfiguration>
            """
        
        let data = content.convertToData()
        
        let headers = [
            "Host": host
        ]
        let awsHeaders = try signer.headers(for: .PUT, urlString: url.absoluteString, region: region, headers: headers, payload: .bytes(data))
        
        return try make(request: url, method: .PUT, headers: awsHeaders, data: data, on: container).map(to: Void.self) { response in
            if response.http.status == .notFound {
                throw Error.notFound
            }
            guard response.http.status == .ok else {
                if let error = try? response.decode(to: ErrorMessage.self) {
                    throw Error.errorResponse(response.http.status, error)
                } else {
                    throw Error.badResponse(response)
                }
            }
            return Void()
        }
    }
    
}
