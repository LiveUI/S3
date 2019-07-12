//
//  S3+Delete.swift
//  S3
//
//  Created by Ondrej Rafaj on 11/05/2018.
//

import Foundation
import Vapor


// Helper S3 extension for deleting files by their URL/path
extension S3 {
    
    // MARK: Delete
    
    /// Delete file from S3
    public func delete(file: LocationConvertible, headers strHeaders: [String: String], on eventLoop: EventLoop) -> EventLoopFuture<Void> {
        let headers: HTTPHeaders
        let url: URL

        do {
            url = try makeURLBuilder().url(file: file)
            headers = try signer.headers(for: .DELETE, urlString: url.absoluteString, headers: strHeaders, payload: .none)
        } catch let error {
            return eventLoop.future(error: error)
        }

        return make(request: url, method: .DELETE, headers: headers, data: emptyData(), on: eventLoop).flatMapThrowing(self.check).transform(to: ())
    }
    
    /// Delete file from S3
    public func delete(file: LocationConvertible, on eventLoop: EventLoop) -> EventLoopFuture<Void> {
        return
            delete(file: file, headers: [:], on: eventLoop)
    }
    
}
