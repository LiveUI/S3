import OpenCrypto


extension HMAC {
    
    static func signature(_ stringToSign: String, key: String) -> String {
        let signature = HMAC<H>.authenticationCode(
            for: [UInt8](stringToSign.utf8),
            using: SymmetricKey(data: [UInt8](key.utf8))
        ).description
        return signature
    }
    
}
