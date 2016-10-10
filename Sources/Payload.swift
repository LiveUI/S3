//
//  Payload.swift
//  S3SignerAWS
//
//  Created by Justin on 10/10/16.
//
//

import Core
import Hash

public enum Payload {
    case bytes(Bytes)
    case none
    case unsigned
    
    func hashed() throws -> String {
        switch self {
        case .bytes(let bytes):
            return try Hash.make(.sha256, bytes).hexString
        case .none:
            return try Hash.make(.sha256, "".bytes).hexString
        case .unsigned:
            return "UNSIGNED-PAYLOAD"
            
        }
    }
    
    var isBytes: Bool {
        switch self {
        case .bytes( _), .none:
            return true
        default:
            return false
        }
    }
    
    var isUnsigned: Bool {
        switch self {
        case .unsigned:
            return true
        default:
            return false
        }
    }
    
    var bytes: Bytes {
        switch self {
        case .bytes(let bytes):
            return bytes
        default:
            return "".bytes
        }
    }
}
