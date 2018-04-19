import Foundation
import Vapor


struct AWSEncoding {
    static let QueryAllowed = "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ-._~=&"
    static let PathAllowed  = "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ-._~/"
}


extension String {
    
    func awsStringEncoding(_ type: String) -> String? {
        let allowed = NSMutableCharacterSet.alphanumeric()
        allowed.addCharacters(in: type)
        return self.addingPercentEncoding(withAllowedCharacters: allowed as CharacterSet)
    }
    
}
