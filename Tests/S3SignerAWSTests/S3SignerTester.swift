import Foundation
@testable import S3SignerAWS


/// A way to inject specific required info for aws signing tests without introducing to S3SignerAWS.
class S3SignerTester: S3SignerAWS {
	
	var overridenDate: Dates?
	
	var overrideService: String = "service"
	
	override var service: String {
		return overrideService
	}
	
	override func getDates(date: Date) -> Dates {
		return overridenDate ?? Dates(date: date)
	}
}

extension Dates {
	init(longDate: String) {
		self.short = longDate.substring(to: longDate.index(longDate.startIndex, offsetBy: 8))
		self.long = longDate
	}
}
