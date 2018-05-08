import Foundation


struct Dates {
    
    /// The ISO8601 basic format timestamp of signature creation.  YYYYMMDD'T'HHMMSS'Z'.
    let long: String
    
    /// The short timestamp of signature creation. YYYYMMDD.
    let short: String

    init(_ date: Date) {
        self.short = date.timestampShort
        self.long = date.timestampLong
    }
    
}


extension Date {
    
    private static let shortDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd"
        formatter.timeZone = TimeZone(abbreviation: "UTC")
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()
    
    private static let longDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd'T'HHmmss'Z'"
        formatter.timeZone = TimeZone(abbreviation: "UTC")
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()
    
    var timestampShort: String {
        return Date.shortDateFormatter.string(from: self)
    }
    
    var timestampLong: String {
        return Date.longDateFormatter.string(from: self)
    }
    
}
