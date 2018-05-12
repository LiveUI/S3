//
//  Error+S3.swift
//  S3
//
//  Created by Ondrej Rafaj on 12/05/2018.
//

import Foundation
@_exported import Vapor


extension Error {
    
    /// Return S3 Error if possible
    public func s3Error() -> S3.Error? {
        guard let error = self as? S3.Error else {
            return nil
        }
        return error
    }
    
    /// Return S3 ErrorMessage if possible
    public func s3ErroMessage() -> ErrorMessage? {
        guard let error = self as? S3.Error else {
            return nil
        }
        switch error {
        case .errorResponse(_, let errorMessage):
            return errorMessage
        default:
            return nil
        }
    }
    
    /// Return S3 error status code if possible
    public func s3ErroCode() -> HTTPResponseStatus? {
        guard let error = self as? S3.Error else {
            return nil
        }
        switch error {
        case .errorResponse(let errorCode, _):
            return errorCode
        default:
            return nil
        }
    }
    
}
