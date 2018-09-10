import Foundation
@testable import S3Signer

/// A way to inject specific required info for aws signing tests without introducing to S3Signer.
//class S3SignerTester: S3Signer {
//    
//    var overridenDate: Dates?
//
//    func getDates(_ date: Date) -> Dates {
//        return overridenDate ?? super.getDates(date)
//    }
//}

//extension Dates {
//    init(longDate: String) {
//        self.short = String(longDate[..<String.Index(encodedOffset: 8)])
//        self.long = longDate
//    }
//}
