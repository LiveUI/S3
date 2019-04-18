//
//  BucketResults.swift
//  S3
//
//  Created by Ondrej Rafaj on 12/05/2018.
//

import Foundation
import Vapor


public struct BucketResults: Content {
    
    /// Name of the bucket
    public let name: String
    
    /// Keys that begin with the indicated prefix
    public let prefix: String?
    
    /**
     All of the keys rolled up into a common prefix count as a single return when calculating the number of returns. See MaxKeys.
     
     A response can contain CommonPrefixes only if you specify a delimiter.
     CommonPrefixes contains all (if there are any) keys between Prefix and the next occurrence of the string specified by a delimiter.
     CommonPrefixes lists keys that act like subdirectories in the directory specified by Prefix.
     For example, if the prefix is notes/ and the delimiter is a slash (/) as in notes/summer/july, the common prefix is notes/summer/. All of the keys that roll up into a common prefix count as a single return when calculating the number of returns. See MaxKeys
    */
    public let commonPrefixes: [CommonPrefix]?
    
    /// Returns the number of keys included in the response. The value is always less than or equal to the MaxKeys value
    public let keyCount: Int?
    
    /// The maximum number of keys returned in the response body
    public let maxKeys: Int
    
    /// Causes keys that contain the same string between the prefix and the first occurrence of the delimiter to be rolled up into a single result element in the CommonPrefixes collection. These rolled-up keys are not returned elsewhere in the response. Each rolled-up result counts as only one return against the MaxKeys value
    public let delimiter: String?
    
    /// Encoding type used by Amazon S3 to encode object key names in the XML response
    public let encodingType: String?
    
    /// Pagination; If StartAfter was sent with the request, it is included in the response
    public let startAfter: String?
    
    /// If the response is truncated, Amazon S3 returns this parameter with a continuation token. You can specify the token as the continuation-token in your next request to retrieve the next set of keys
    public let nextContinuationToken: String?
    
    /// Set to false if all of the results were returned. Set to true if more keys are available to return. If the number of results exceeds that specified by MaxKeys, all of the results might not be returned
    public let isTruncated: Bool
    
    /// Objects
    public let objects: [Object]?
    
    enum CodingKeys: String, CodingKey {
        case name = "Name"
        case prefix = "Prefix"
        case commonPrefixes = "CommonPrefixes"
        case keyCount = "KeyCount"
        case maxKeys = "MaxKeys"
        case delimiter = "Delimiter"
        case encodingType = "Encoding-Type"
        case startAfter = "StartAfter"
        case nextContinuationToken = "NextContinuationToken"
        case isTruncated = "IsTruncated"
        case objects = "Contents"
    }
    
}


public struct CommonPrefix: Codable {
    
    /// Common prefix name
    let path: String
    
    enum CodingKeys: String, CodingKey {
        case path = "Prefix"
    }
    
}
