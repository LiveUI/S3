import Foundation
import Vapor


enum AWSEncoding: String {
    case queryAllowed = "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ-._~=&"
    case pathAllowed = "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ-._~/"
}


extension String {
    
    func encode(type: AWSEncoding) -> String? {
        let allowed = NSMutableCharacterSet.alphanumeric()
        allowed.addCharacters(in: type.rawValue)
        return self.addingPercentEncoding(withAllowedCharacters: allowed as CharacterSet)
    }
    
}
