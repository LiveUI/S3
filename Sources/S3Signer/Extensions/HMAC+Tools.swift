import OpenCrypto


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
    
    var bytes: [UInt8] {
        var byteBuffer: [UInt8] = []
        withUnsafeBytes {
            byteBuffer.append(contentsOf: $0)
        }
        return byteBuffer
    }
    
    var data: Data {
        return Data(bytes)
    }
    
}
