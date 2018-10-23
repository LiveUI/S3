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
    public func move(file: LocationConvertible, to destination: LocationConvertible, headers: [String: String], on container: Container) throws -> EventLoopFuture<File.CopyResponse> {
        return try copy(file: file, to: destination, headers: headers, on: container).flatMap(to: File.CopyResponse.self) { copyResult in
            return try self.delete(file: file, on: container).map(to: File.CopyResponse.self) { _ in
                return copyResult
            }
        }
    }
    
}
