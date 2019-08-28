import Foundation


enum AWSEncoding: String {
    case queryAllowed = "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ-._~=&"
    case pathAllowed = "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ-._~/"
}


extension String {
    
    func encode(type: AWSEncoding) -> String? {
        var allowed = CharacterSet.alphanumerics
        allowed.insert(charactersIn: type.rawValue)
        return addingPercentEncoding(withAllowedCharacters: allowed)
    }

    var bytes: [UInt8] { .init(utf8) }
    
}
