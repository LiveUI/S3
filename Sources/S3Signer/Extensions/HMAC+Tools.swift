import Crypto


extension HMAC {
    
    static func signature(_ stringToSign: String, key: [UInt8]) -> HashedAuthenticationCode<H> {
        let signature = HMAC<H>.authenticationCode(
            for: stringToSign.bytes,
            using: .init(data: key)
        )
        return signature
    }
    
    static func signature(_ stringToSign: String, key: HashedAuthenticationCode<H>) -> HashedAuthenticationCode<H> {
        let signature = HMAC<H>.authenticationCode(
            for: stringToSign.bytes,
            using: .init(data: key)
        )
        return signature
    }
    
}

extension HashedAuthenticationCode {
    
    var data: Data {
        return Data(self)
    }
    
}
