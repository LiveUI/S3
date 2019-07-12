//
//  S3+Copy.swift
//  S3
//
//  Created by Topic, Zdenek on 17/10/2018.
//

import Foundation
import Vapor


extension S3 {
    
    // MARK: Copy
    
    /// Copy file on S3
    public func copy(file: LocationConvertible, to: LocationConvertible, headers strHeaders: [String: String], on eventLoop: EventLoop) -> EventLoopFuture<File.CopyResponse> {
        let headers: HTTPHeaders
        let destinationUrl: URL

        do {
            destinationUrl = try makeURLBuilder().url(file: to)

            var awsHeaders: [String: String] = strHeaders
            awsHeaders["x-amz-copy-source"] = "\(file.bucket ?? defaultBucket)/\(file.path)"
            headers = try signer.headers(
                for: .PUT,
                urlString: destinationUrl.absoluteString,
                headers: awsHeaders,
                payload: .none
            )
        } catch let error {
            return eventLoop.future(error: error)
        }
        
        var request = ClientRequest()
        request.method = .PUT
        request.headers = headers
        request.url = URI(string: destinationUrl.description)

        return self.execute(request, on: eventLoop).flatMapThrowing { response in
            return try self.check(response).content.decode(File.CopyResponse.self)
        }
    }
    
}
