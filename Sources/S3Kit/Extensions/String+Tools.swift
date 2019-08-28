import Foundation


extension String {
    
    func finished(with string: String) -> String {
        if let last = last, String(last) == string {
            return self
        }
        return appending(string)
    }

    var bytes: [UInt8] { .init(utf8) }
    
}
