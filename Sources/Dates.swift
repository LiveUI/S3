import Foundation.NSDate

internal struct Dates {
	
	/// The ISO8601 basic format timestamp of signature creation.  YYYYMMDD'T'HHMMSS'Z'.
	internal let short: String
	
	
    /// The short timestamp of signature creation. YYYYMMDD.
    internal let long: String
}

extension Dates {
	
	internal init(date: Date) {
		short = date.timestampShort
		long = date.timestampLong
	}
}

extension Date {
	
	private static let shortdateFormatter: DateFormatter = {
		let formatter = DateFormatter()
		formatter.dateFormat = "yyyyMMdd"
		formatter.timeZone = TimeZone(abbreviation: "UTC")
		formatter.locale = Locale(identifier: "en_US_POSIX")
		return formatter
	}()
	
	private static let longdateFormatter: DateFormatter = {
		let formatter = DateFormatter()
		formatter.dateFormat = "yyyyMMdd'T'HHmmss'Z'"
		formatter.timeZone = TimeZone(abbreviation: "UTC")
		formatter.locale = Locale(identifier: "en_US_POSIX")
		return formatter
	}()
	
	internal var timestampShort: String {
		return Date.shortdateFormatter.string(from: self)
	}
	
	internal var timestampLong: String {
		return Date.longdateFormatter.string(from: self)
	}
}
