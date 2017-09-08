import Core
import Crypto

/// The Payload associated with a request.
///
/// - bytes: The bytes of the request.
/// - none: No payload is in the request. i.e. GET request.
/// - unsigned: The size of payload will not go into signature calcuation. Useful if size is unknown at time of signature creation. Less secure as the payload can be changed and the signature won't be effected.
public enum Payload {
    case bytes(Bytes)
    case none
    case unsigned
	
	internal var bytes: Bytes {
		switch self {
		case .bytes(let bytes):
			return bytes
		default:
			return "".bytes
		}
	}
	
	/// Hash the payload being sent to AWS.
	/// - Bytes: are hashed using SHA256
    /// - None: Guaranteed no payload being sent, requires an empty string SHA256.
	/// - Unsigned: Any size payload will be accepted, wasn't considered in part of the signature.
	///
    /// - Returns: The hashed hexString.
    /// - Throws: Hash Error.
    internal func hashed() throws -> String {
        switch self {
        case .bytes(let bytes):
            return try Hash.make(.sha256, bytes).hexString
        case .none:
            return try Hash.make(.sha256, "".bytes).hexString
        case .unsigned:
            return "UNSIGNED-PAYLOAD"
            
        }
    }
    
    internal var isBytes: Bool {
        switch self {
        case .bytes( _), .none:
            return true
        default:
            return false
        }
    }
	
	internal func size() -> String {
		switch self {
		case .bytes, .none:
			return self.bytes.count.description
		case .unsigned:
			return "UNSIGNED-PAYLOAD"
		}
	}
    
    internal var isUnsigned: Bool {
        switch self {
        case .unsigned:
            return true
        default:
            return false
        }
    }
}
