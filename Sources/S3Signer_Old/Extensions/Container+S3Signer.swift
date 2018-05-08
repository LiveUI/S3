//
//  Container+S3Signer.swift
//  S3Signer
//
//  Created by Ondrej Rafaj on 19/04/2018.
//

import Foundation
import Vapor


extension Container {
    
    /// Returns S3 signer
    public func makeS3Signer() throws -> S3Signer {
        return try make()
    }
    
}
