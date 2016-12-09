//
//  Region.swift
//  S3SignerAWS
//
//  Created by on 10/10/16.
//
//

public enum Region: String {
    
    case usEast1_Virginia = "us-east-1"
    case usEast2_Ohio = "us-east-2"
    case usWest1 = "us-west-1"
    case usWest2 = "us-west-2"
    case euWest1 = "eu-west-1"
    case euCentral1 = "eu-central-1"
    case apSouth1 = "ap-south-1"
    case apSoutheast1 = "ap-southeast-1"
    case apSoutheast2 = "ap-southeast-2"
    case apNortheast1 = "ap-northeast-1"
    case apNortheast2 = "ap-northeast-2"
    case saEast1 = "sa-east-1"
    
    
   public var host: String {
        switch self {
        case .usEast1_Virginia: return "s3.amazonaws.com"
        case .usEast2_Ohio: return "s3.us-east-2.amazonaws.com"
        case .usWest1: return "s3-us-west-1.amazonaws.com"
        case .usWest2: return "s3-us-west-2.amazonaws.com"
        case .euWest1: return "s3-eu-west-1.amazonaws.com"
        case .euCentral1: return "s3.eu-central-1.amazonaws.com"
        case .apSouth1: return "s3.ap-south-1.amazonaws.com"
        case .apSoutheast1: return "s3-ap-southeast-1.amazonaws.com"
        case .apSoutheast2: return "s3-ap-southeast-2.amazonaws.com"
        case .apNortheast1: return "s3-ap-northeast-1.amazonaws.com"
        case .apNortheast2: return "s3.ap-northeast-2.amazonaws.com"
        case .saEast1: return "s3-sa-east-1.amazonaws.com"
        
        }
    }
}
