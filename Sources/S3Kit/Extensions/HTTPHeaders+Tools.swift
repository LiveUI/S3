import Foundation


extension HTTPHeaders {
    
    func string(_ name: String) -> String? {
        return self[name].first
    }
    
    func int(_ name: String) -> Int? {
        guard let headerValue = string(name) else {
            return nil
        }
        return Int(headerValue)
    }
    
    func date(_ name: String) -> Date? {
        guard let headerValue = string(name) else {
            return nil
        }
        return S3.headerDateFormatter.date(from: headerValue)
    }
    
}
