//
//  S3.swift
//  S3
//
//  Created by Ondrej Rafaj on 18/04/2018.
//

import Foundation
@testable import S3
import Vapor


//class S3Mock: S3Client {
//    
//   
//}

class S3Mock: S3 {
    init() throws {
        try super.init(defaultBucket: "default", signer: S3Signer(S3Signer.Config(accessKey: "SomeAccessKey", secretKey: "SomeSecretKey", region: .usEast1)))
    }
}
