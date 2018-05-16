//
//  ErrorMessage.swift
//  S3
//
//  Created by Ondrej Rafaj on 12/05/2018.
//

import Foundation
import Vapor


/// Generic response error message
public struct ErrorMessage: Content {
    
    /// Error code
    public let code: String
    
    /// Error message
    public let message: String
    
    /// Bucket involved?
    public let bucket: String?
    
    /// Header involved?
    public let endpoint: String?
    
    /// Header involved?
    public let header: String?
    
    /// Request Id
    public let requestId: String?
    
    /// Host Id
    public let hostId: String?
    
    enum CodingKeys: String, CodingKey {
        case code = "Code"
        case message = "Message"
        case bucket = "BucketName"
        case endpoint = "Endpoint"
        case header = "Header"
        case requestId = "RequestId"
        case hostId = "HostId"
    }
    
}
