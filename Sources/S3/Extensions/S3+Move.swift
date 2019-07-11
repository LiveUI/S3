//
//  S3+Copy.swift
//  S3
//
//  Created by Ondrej Rafaj on 23/10/2018.
//

import Foundation
import Vapor


extension S3 {
    
    // MARK: Move
    
    /// Copy file on S3
    public func move(file: LocationConvertible, to destination: LocationConvertible, headers: [String: String], on eventLoop: EventLoop) -> EventLoopFuture<File.CopyResponse> {
        return copy(file: file, to: destination, headers: headers, on: eventLoop).flatMap { copyResult in
            return self.delete(file: file, on: eventLoop).transform(to: copyResult)
        }
    }
    
}
