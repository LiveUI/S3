@testable import S3SignerAWS
import XCTest

class S3SignerAWSTests: XCTestCase {

	static var allTests = [
		("test_TimeFromNow_Expiration", test_TimeFromNow_Expiration),
		("test_Payload_bytes", test_Payload_bytes),
		("test_Payload_none", test_Payload_none),
		("test_Payload_unsigned", test_Payload_unsigned),
		("test_Dates_formatting", test_Dates_formatting),
		("test_Region_host", test_Region_host),
		("test_S3Signer_get_dates", test_S3Signer_get_dates),
		("test_S3Signer_service", test_S3Signer_service),
		("test_Put_with_pathExtension_adds_content_length_And_content_type", test_Put_with_pathExtension_adds_content_length_And_content_type),
		("test_Throws_on_bad_url", test_Throws_on_bad_url),
		("test_UnsignedPayload_adds_proper_content_header", test_UnsignedPayload_adds_proper_content_header)
	]
	
	var signer: S3SignerAWS!
	
	override func setUp() {
		super.setUp()
		signer = S3SignerAWS(accessKey: "SomeAccessKey", secretKey: "SomeSecretKey", region: .usEast1_Virginia)
	}
	
	func test_Dates_formatting() {
		let date = Date()
		let dates = Dates(date: date)
		XCTAssertEqual(dates.short, date.timestampShort)
		XCTAssertEqual(dates.long, date.timestampLong)
	}
	
	func test_TimeFromNow_Expiration() {
		let thiryMinutes = TimeFromNow.thirtyMinutes
		XCTAssertEqual(thiryMinutes.expiration, 60 * 30)
		let oneHour = TimeFromNow.oneHour
		XCTAssertEqual(oneHour.expiration, 60 * 60)
		let threeHours = TimeFromNow.threeHours
		XCTAssertEqual(threeHours.expiration, 60 * 60 * 3)
	}
	
	func test_Payload_bytes() {
		let sampleBytes = "S3SignerAWS".bytes
		let payloadBytes = Payload.bytes(sampleBytes)
		let payloadSize = sampleBytes.count.description
		XCTAssertTrue(payloadBytes.isBytes)
		XCTAssertFalse(payloadBytes.isUnsigned)
		XCTAssertEqual(sampleBytes, payloadBytes.bytes)
		XCTAssertEqual(payloadBytes.size(), payloadSize)
	}

	func test_Payload_none() {
		let sampleBytes = "".bytes
		let payloadNone = Payload.none
		let payloadSize = sampleBytes.count.description
		XCTAssertTrue(payloadNone.isBytes)
		XCTAssertFalse(payloadNone.isUnsigned)
		XCTAssertEqual(sampleBytes, payloadNone.bytes)
		XCTAssertEqual(payloadNone.size(), payloadSize)
	}
	
	func test_Payload_unsigned() {
		let unsigned = "UNSIGNED-PAYLOAD"
		let payloadUnsigned = Payload.unsigned
		XCTAssertFalse(payloadUnsigned.isBytes)
		XCTAssertTrue(payloadUnsigned.isUnsigned)
		XCTAssertEqual(unsigned, payloadUnsigned.size())
		XCTAssertEqual(unsigned, try! payloadUnsigned.hashed())
	}
	
	func test_Region_host() {
		XCTAssertEqual(Region.usEast1_Virginia.host, "s3.amazonaws.com")
		XCTAssertEqual(Region.usEast2_Ohio.host, "s3.us-east-2.amazonaws.com")
		XCTAssertEqual(Region.usWest1.host, "s3-us-west-1.amazonaws.com")
		XCTAssertEqual(Region.usWest2.host, "s3-us-west-2.amazonaws.com")
		XCTAssertEqual(Region.euWest1.host, "s3-eu-west-1.amazonaws.com")
		XCTAssertEqual(Region.euCentral1.host, "s3.eu-central-1.amazonaws.com")
		XCTAssertEqual(Region.apSouth1.host, "s3.ap-south-1.amazonaws.com")
		XCTAssertEqual(Region.apSoutheast1.host, "s3-ap-southeast-1.amazonaws.com")
		XCTAssertEqual(Region.apSoutheast2.host, "s3-ap-southeast-2.amazonaws.com")
		XCTAssertEqual(Region.apNortheast1.host, "s3-ap-northeast-1.amazonaws.com")
		XCTAssertEqual(Region.apNortheast2.host, "s3.ap-northeast-2.amazonaws.com")
		XCTAssertEqual(Region.saEast1.host, "s3-sa-east-1.amazonaws.com")
	}
	
	func test_S3Signer_get_dates() {
		let date = Date()
		let dates = signer.getDates(date: date)
		XCTAssertEqual(dates.short, date.timestampShort)
		XCTAssertEqual(dates.long, date.timestampLong)
	}
	
	func test_S3Signer_service() {
		XCTAssertEqual(signer.service, "s3")
	}
	
	func test_Put_with_pathExtension_adds_content_length_And_content_type() {
		let randomBytesMessage = "Welcome to Amazon S3.".bytes
		let headers = try! signer.authHeaderV4(
			httpMethod: .put,
			urlString: "https://www.someURL.com/someFile.txt",
			payload: .bytes(randomBytesMessage))
		
		XCTAssertNotNil(headers["Content-Length"])
		XCTAssertNotNil(headers["Content-Type"])
		XCTAssertEqual(headers["Content-Length"], Payload.bytes(randomBytesMessage).size())
		XCTAssertEqual(headers["Content-Type"], "txt")
	}
	
	func test_Throws_on_bad_url() {
		XCTAssertThrowsError(try signer.authHeaderV4(httpMethod: .get, urlString: "", payload: .none))
		XCTAssertThrowsError(try signer.presignedURLV4(httpMethod: .get, urlString: "", expiration: .thirtyMinutes, headers: [:]))
	}
	
	func test_UnsignedPayload_adds_proper_content_header() {
		let headers = try! signer.authHeaderV4(
			httpMethod: .get, urlString:
			"https://www.someURL.com",
			payload: .unsigned)
		XCTAssertEqual(headers["x-amz-content-sha256"], "UNSIGNED-PAYLOAD")
	}
}
