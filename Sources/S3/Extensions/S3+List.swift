//
//  S3+List.swift
//  S3
//
//  Created by Ondrej Rafaj on 12/05/2018.
//

import Foundation


// Helper S3 extension for getting file indexes
extension S3 {
    
    /// Get list of objects
    public func list(bucket: String, region: Region? = nil, headers: [String: String], prefix: String?, delimiter: String?, on container: Container) throws -> Future<BucketResults> {
        let region = region ?? signer.config.region
        guard let baseUrl = URL(string: region.hostUrlString(bucket: bucket)), let host = baseUrl.host,
            var components = URLComponents(string: baseUrl.absoluteString) else {
            throw S3.Error.invalidUrl
        }
        var queryItems = [ URLQueryItem(name: "list-type", value: "2") ]
        if let prefix = prefix, !prefix.isEmpty {
            queryItems.append(URLQueryItem(name: "prefix", value: prefix))
        }
        if let delimiter = delimiter, !delimiter.isEmpty {
            queryItems.append(URLQueryItem(name: "delimiter", value: delimiter))
        }
        components.queryItems = queryItems
        guard let url = components.url else {
            throw S3.Error.invalidUrl
        }
        var headers = headers
        headers["host"] = host
        let awsHeaders = try signer.headers(for: .GET, urlString: url.absoluteString, region: region, bucket: bucket, headers: headers, payload: .none)
        return try make(request: url, method: .GET, headers: awsHeaders, data: emptyData(), on: container).map(to: BucketResults.self) { response in
            try self.check(response)
            return try response.decode(to: BucketResults.self)
        }
    }
    
    /// Get list of objects
    public func list(bucket: String, region: Region? = nil, prefix: String?, delimiter: String?, on container: Container) throws -> Future<BucketResults> {
        return try list(bucket: bucket, region: region, headers: [:], prefix: prefix, delimiter: delimiter, on: container)
    }
    
    /// Get list of objects
    public func list(bucket: String, region: Region? = nil, on container: Container) throws -> Future<BucketResults> {
        return try list(bucket: bucket, region: region, headers: [:], prefix: nil, delimiter: nil, on: container)
    }
    
}
