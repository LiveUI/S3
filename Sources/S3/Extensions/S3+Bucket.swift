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
    
    /// Delete file from S3
    public func create(bucket: String, on container: Container) throws -> Future<Void> {
        let signer = try container.makeS3Signer()
        
        let hostString = host(bucket: bucket)
        let url = URL(string: "https://" + hostString)!
        
        let data = """
<CreateBucketConfiguration xmlns="http://s3.amazonaws.com/doc/2006-03-01/">
    <LocationConstraint>\(signer.config.region.rawValue)</LocationConstraint>
</CreateBucketConfiguration>
""".convertToData()
        
        var headers = [
            "Host": hostString
        ]
        let awsHeaders = try signer.headers(for: .PUT, urlString: hostString, headers: headers, payload: .bytes(data))
        
        return try make(request: url, method: .PUT, headers: awsHeaders, data: data, on: container).map(to: Void.self) { response in
            if response.http.status == .notFound {
                throw Error.notFound
            }
            guard response.http.status == .ok || response.http.status == .noContent else {
                throw Error.badResponse(response)
            }
            return Void()
        }
    }
    
}
