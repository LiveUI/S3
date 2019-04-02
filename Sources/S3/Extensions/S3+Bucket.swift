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
extension S3 {
    
    // MARK: Buckets
    
    /// Get bucket location
    public func location(bucket: String, on container: Container) throws -> Future<Region> {
        let builder = urlBuilder(for: container)
        let region = Region.euWest2
        let url = try builder.url(region: region, bucket: bucket, path: nil)
        
        let awsHeaders = try signer.headers(for: .GET, urlString: url.absoluteString, region: region, payload: .none)
        return try make(request: url, method: .GET, headers: awsHeaders, data: emptyData(), on: container).map(to: Region.self) { response in
            if response.http.status == .notFound {
                throw Error.notFound
            }
            if response.http.status == .ok {
                return region
            } else {
                if let error = try? response.decode(to: ErrorMessage.self), error.code == "PermanentRedirect", let endpoint = error.endpoint {
                    if endpoint == "s3.amazonaws.com" {
                        return Region.usEast1
                    } else {
                        // Split bucket.s3.region.amazonaws.com into parts
                        // Drop .com and .amazonaws
                        // Get region (last part)
                        guard let regionString = endpoint.split(separator: ".").dropLast(2).last?.lowercased() else {
                            throw Error.badResponse(response)
                        }
                        return Region(name: .init(regionString))
                    }
                } else {
                    throw Error.badResponse(response)
                }
            }
        }
    }
    
    /// Delete bucket
    public func delete(bucket: String, region: Region? = nil, on container: Container) throws -> Future<Void> {
        let builder = urlBuilder(for: container)
        let url = try builder.url(region: region, bucket: bucket, path: nil)
        
        let awsHeaders = try signer.headers(for: .DELETE, urlString: url.absoluteString, region: region, payload: .none)
        return try make(request: url, method: .DELETE, headers: awsHeaders, data: emptyData(), on: container).map(to: Void.self) { response in
            try self.check(response)
            return Void()
        }
    }
    
    /// Create a bucket
    public func create(bucket: String, region: Region? = nil, on container: Container) throws -> Future<Void> {
        let region = region ?? signer.config.region
        
        let builder = urlBuilder(for: container)
        let url = try builder.url(region: region, bucket: bucket, path: nil)
        
        let content = """
            <CreateBucketConfiguration xmlns="http://s3.amazonaws.com/doc/2006-03-01/">
                <LocationConstraint>\(region.name)</LocationConstraint>
            </CreateBucketConfiguration>
            """
        
        let data = content.convertToData()
        let awsHeaders = try signer.headers(for: .PUT, urlString: url.absoluteString, region: region, payload: .bytes(data))
        return try make(request: url, method: .PUT, headers: awsHeaders, data: data, on: container).map(to: Void.self) { response in
            try self.check(response)
            return Void()
        }
    }
    
}
