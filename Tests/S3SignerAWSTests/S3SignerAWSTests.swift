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
		("test_S3Signer_service", test_S3Signer_service)
	]
	
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
	
	func test_Dates_formatting() {
		let date = Date()
		let dates = Dates(date: date)
		XCTAssertEqual(dates.short, date.timestampShort)
		XCTAssertEqual(dates.long, date.timestampLong)
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
		let signer = S3SignerAWS(accessKey: "ACCESSKEY", secretKey: "SECRETKEY", region: Region.usEast1_Virginia)
		let date = Date()
		let dates = signer.getDates(date: date)
		XCTAssertEqual(dates.short, date.timestampShort)
		XCTAssertEqual(dates.long, date.timestampLong)
	}
	
	func test_S3Signer_service() {
		let signer = S3SignerAWS(accessKey: "ACCESSKEY", secretKey: "SECRETKEY", region: Region.usEast1_Virginia)
		XCTAssertEqual(signer.service, "s3")
	}
}
