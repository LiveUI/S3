//
//  Bucket.swift
//  S3
//
//  Created by Ondrej Rafaj on 11/05/2018.
//

import Foundation
import Vapor


/// Base object for /buckets endpoint
public struct BucketsInfo: Content {
    
    /// Owner
    public let owner: Owner
    
    /// Available buckets
    public let buckets: [Bucket]
    
    /// Coding keys
    enum CodingKeys: String, CodingKey {
        case owner = "Owner"
        case additionalInfo = "Buckets"
    }
    
    /// Additional (helper) coding keys
    enum AdditionalInfoKeys: String, CodingKey {
        case buckets = "Bucket"
    }
    
    /// Init from Decoder
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        owner = try values.decode(Owner.self, forKey: .owner)
        
        let additionalInfo = try values.nestedContainer(keyedBy: AdditionalInfoKeys.self, forKey: .additionalInfo)
        
        buckets = try additionalInfo.decode([Bucket].self, forKey: .buckets)
    }
    
    /// Encode
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(owner, forKey: .owner)
        
        var additionalInfo = container.nestedContainer(keyedBy: AdditionalInfoKeys.self, forKey: .additionalInfo)
        
        try additionalInfo.encode(buckets, forKey: .buckets)
    }
    
}


/// Bucket model
public struct Bucket: Content {
    
    /// Creating new bucket
    public struct New: Codable {
        
        /// Name of the new bucket
        public let name: String
        
        /// New bucket initializer
        public init(name: String) {
            self.name = name
        }
        
        enum CodingKeys: String, CodingKey {
            case name = "Name"
        }
        
    }
    
    /// Name of a bucket
    public let name: String

    /// Bucket creation date
    public let created: Date

    enum CodingKeys: String, CodingKey {
        case name = "Name"
        case created = "CreationDate"
    }
    
}
