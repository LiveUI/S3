//
//  S3+Service.swift
//  S3
//
//  Created by Ondrej Rafaj on 11/05/2018.
//

import Foundation
import Vapor
import XMLCoding


// Helper S3 extension for working with services
extension S3 {
    
    // MARK: Buckets
    
    /// Get list of buckets
    public func buckets(on container: Container) throws -> Future<BucketsInfo> {
        let builder = urlBuilder(for: container)
        let url = try builder.plain(region: nil)
        let headers = try signer.headers(for: .GET, urlString: url.absoluteString, payload: .none)
        return try make(request: url, method: .GET, headers: headers, data: emptyData(), on: container).map(to: BucketsInfo.self) { response in
            try self.check(response)
            return try response.decode(to: BucketsInfo.self)
        }
    }
    
}
