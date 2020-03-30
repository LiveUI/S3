@testable import S3Signer
import XCTest


class BaseTestCase: XCTestCase {

    let accessKey = "AKIAIOSFODNN7EXAMPLE"
    let secretKey = "wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY"

    var overridenDate: Dates!
    var signer: S3Signer!
    var region: Region!

    override func setUp() {
        super.setUp()
        region = Region.usEast1
        signer = try! S3Signer(S3Signer.Config(accessKey: accessKey, secretKey: secretKey, region: region, defaultBucket: ""))
        
        // this is the "seconds" representation of "20130524T000000Z"
        overridenDate = Dates(Date(timeIntervalSince1970: (60*60*24) * 15849))

        if let s = try? S3Signer(S3Signer.Config(accessKey: accessKey, secretKey: secretKey, region: region, defaultBucket: "")) {
            signer = s
        } else {
            XCTFail("Could not intialize signer")
        }
    }
    
}
