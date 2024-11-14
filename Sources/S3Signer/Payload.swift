import Foundation
import Crypto


/// Payload object
public enum Payload {
    
    /// Data payload
    case bytes(Data)
    
    /// No payload
    case none
    
    /// Unsigned payload
    case unsigned
    
}

extension Payload {
    
    var bytes: Data {
        switch self {
        case .bytes(let bytes):
            return bytes
        default:
            return Data()
        }
    }
    
    func hashed() -> String {
        switch self {
        case .bytes(let bytes):
            return SHA256.hash(data: [UInt8](bytes)).description
        case .none:
            return SHA256.hash(data: []).description
        case .unsigned:
            return "UNSIGNED-PAYLOAD"
        }
    }
    
    var isBytes: Bool {
        switch self {
        case .bytes(_), .none:
            return true
        default:
            return false
        }
    }
    
    func size() -> String {
        switch self {
        case .unsigned:
            return "UNSIGNED-PAYLOAD"
        default:
            return bytes.count.description
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
    
}
