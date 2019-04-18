//
// Created by Florent Pillet on 2019-01-25.
//

@testable import S3Signer
import XCTest

class S3SignerV2Tests: BaseTestCase {
	override func setUp() {
		super.setUp()
		signer = try! S3Signer(S3Signer.Config(accessKey: accessKey, secretKey: secretKey, region: region, version: .v2))
		if let s = try? S3Signer(S3Signer.Config(accessKey: accessKey, secretKey: secretKey, region: region, version: .v2)) {
			signer = s
		} else {
			XCTFail("Could not intialize signer")
		}
	}

	// TOOD: appropriate testing would try various cases (where URL has signable query items, etc)

	func testSignatureV2_AWS() throws {
		let requestURLString = region.hostUrlString()
		let requestURL = URL(string: requestURLString)!

		let updatedHeaders = try signer.update(headers: [:], url: requestURL, longDate: overridenDate.long, bodyDigest: Payload.none.hashed(), region: region)
		let signature = try signer.generateAuthHeaderV2(.GET, url: requestURL, headers: updatedHeaders, dates: overridenDate, region: region, bucket: nil)

		XCTAssertEqual(signature, "AWS AKIAIOSFODNN7EXAMPLE:6sBgrGyWpHXvBFC/ip2imdLWe1U=")
	}

	func testSignatureV2_AWS_Bucket() throws {
		let requestURLString = region.hostUrlString()
		let requestURL = URL(string: requestURLString)!

		let updatedHeaders = try signer.update(headers: [:], url: requestURL, longDate: overridenDate.long, bodyDigest: Payload.none.hashed(), region: region)
		let signature = try signer.generateAuthHeaderV2(.GET, url: requestURL, headers: updatedHeaders, dates: overridenDate, region: region, bucket: "SomeBucket")

		XCTAssertEqual(signature, "AWS AKIAIOSFODNN7EXAMPLE:MoWa/bEpN+BIPWryvy9dMxSvFsw=")
	}

	func testSignatureV2_CustomHost() throws {
		// since we are not using virtual hosting for custom hosts, signature should be the same
		let region = Region(name: .usEast1, hostName: "some.custom.site.com", useTLS: false)
		let requestURLString =  region.hostUrlString()
		let requestURL = URL(string: requestURLString)!

		let updatedHeaders = try signer.update(headers: [:], url: requestURL, longDate: overridenDate.long, bodyDigest: Payload.none.hashed(), region: region)
		let signature = try signer.generateAuthHeaderV2(.GET, url: requestURL, headers: updatedHeaders, dates: overridenDate, region: region, bucket: "SomeBucket")

		XCTAssertEqual(signature, "AWS AKIAIOSFODNN7EXAMPLE:MoWa/bEpN+BIPWryvy9dMxSvFsw=")
	}
}
