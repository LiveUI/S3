//
//  BucketsInfo.swift
//  S3
//
//  Created by Ondrej Rafaj on 16/05/2018.
//

import Foundation
import Vapor


/// Base object for /buckets endpoint
public struct BucketsInfo: Content {
    
    /// Owner
    public let owner: Owner?
    
    /// Available buckets
    public let buckets: [Bucket]?
    
    /// Max keys
    public let maxKeys: Int?
    
    /// Max keys
    public let truncated: Bool?
    
    /// Coding keys
    enum CodingKeys: String, CodingKey {
        case owner = "Owner"
        case additionalInfo = "Buckets"
        case maxKeys = "MaxKeys"
        case truncated = "IsTruncated"
    }
    
    /// Additional (helper) coding keys
    enum AdditionalInfoKeys: String, CodingKey {
        case buckets = "Bucket"
    }
    
    /// Init from Decoder
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        owner = try? values.decode(Owner.self, forKey: .owner)
        // TODO: Make the following better!!!!!!
        maxKeys = Int((try? values.decode(String.self, forKey: .maxKeys)) ?? "1000") ?? 1000
        truncated = Bool((try? values.decode(String.self, forKey: .truncated)) ?? "false") ?? false
        
        if let additionalInfo = try? values.nestedContainer(keyedBy: AdditionalInfoKeys.self, forKey: .additionalInfo) {
            buckets = try? additionalInfo.decode([Bucket].self, forKey: .buckets)
        } else {
            buckets = nil
        }
    }
    
    /// Encode
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(owner, forKey: .owner)
        
        var additionalInfo = container.nestedContainer(keyedBy: AdditionalInfoKeys.self, forKey: .additionalInfo)
        
        try additionalInfo.encode(buckets, forKey: .buckets)
    }
    
}
