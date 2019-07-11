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
    public func buckets(on eventLoop: EventLoop) -> EventLoopFuture<BucketsInfo> {
        let headers: HTTPHeaders
        let url: URL

        do {
            url = try makeURLBuilder().plain(region: nil)
            headers = try signer.headers(for: .GET, urlString: url.absoluteString, payload: .none)
        } catch let error {
            return eventLoop.future(error: error)
        }

        return make(request: url, method: .GET, headers: headers, data: emptyData(), on: eventLoop).flatMapThrowing { response in
            try self.check(response)
            return try response.decode(to: BucketsInfo.self)
        }
    }
    
}
