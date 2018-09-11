@testable import S3Signer
@testable import S3
import XCTest

class AWSTestSuite: BaseTestCase {
	
	static var allTests = [
		("test_Get_Vanilla", test_Get_Vanilla),
		("test_Get_Vanilla_with_added_headers", test_Get_Vanilla_with_added_headers),
		("test_Post_With_Param_Vanilla", test_Post_With_Param_Vanilla)
	]

	func test_Get_Vanilla() {
        let requestURLString = region.hostUrlString()
        let requestURL = URL(string: requestURLString)!

        let updatedHeaders = try! signer.update(headers: [:], url: requestURL, longDate: overridenDate.long, bodyDigest: Payload.none.hashed(), region: region)

		let expectedCanonRequest = [
			"GET",
			"/",
			"",
			"host:\(region.host)",
            "x-amz-content-sha256:e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855",
			"x-amz-date:20130524T000000Z",
			"",
            "host;x-amz-content-sha256;x-amz-date",
			"e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855"]
			.joined(separator: "\n")
		
        let canonRequest = try! signer.createCanonicalRequest(.GET,
                                                              url: requestURL,
                                                              headers: updatedHeaders,
                                                              bodyDigest: Payload.none.hashed())

		XCTAssertEqual(expectedCanonRequest, canonRequest)
		
		let expectedStringToSign = [
			"AWS4-HMAC-SHA256",
			"20130524T000000Z",
			"20130524/us-east-1/s3/aws4_request",
			"64669d70b364645a9118ecbd15e6f62aee6db08e63d2f74a7f183eb685d871cd"
			].joined(separator: "\n")
		
        let stringToSign = try! signer.createStringToSign(canonRequest,
                                                          dates: overridenDate,
                                                          region: region)

		XCTAssertEqual(expectedStringToSign, stringToSign)
		
		let expectedSignature = "8745d16e49fb5550634d56c2c4bb6841e42d7595f8529cf9ea14d05d51935b20"
        let signature = try! signer.createSignature(stringToSign,
                                                    timeStampShort: overridenDate.short,
                                                    region: region)
		
		XCTAssertEqual(expectedSignature, signature)
		
		let expectedAuthHeader = "AWS4-HMAC-SHA256 Credential=AKIAIOSFODNN7EXAMPLE/20130524/us-east-1/s3/aws4_request, SignedHeaders=host;x-amz-content-sha256;x-amz-date, Signature=8745d16e49fb5550634d56c2c4bb6841e42d7595f8529cf9ea14d05d51935b20"
		
        let authHeader = try! signer.generateAuthHeader(.GET,
                                                        url: requestURL,
                                                        headers: updatedHeaders,
                                                        bodyDigest: Payload.none.hashed(),
                                                        dates: overridenDate,
                                                        region: region)
		
		XCTAssertEqual(expectedAuthHeader, authHeader)
		
		let allExpectedHeadersForRequest = [
			"host": "s3.us-east-1.amazonaws.com",
            "x-amz-content-sha256": "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855",
			"x-amz-date": "20130524T000000Z",
			"authorization": "AWS4-HMAC-SHA256 Credential=AKIAIOSFODNN7EXAMPLE/20130524/us-east-1/s3/aws4_request, SignedHeaders=host;x-amz-content-sha256;x-amz-date, Signature=8745d16e49fb5550634d56c2c4bb6841e42d7595f8529cf9ea14d05d51935b20"
		]

        let allHeadersForRequest = try! signer.headers(for: .GET, urlString: requestURLString, payload: .none, dates: overridenDate)

		XCTAssertEqual(allExpectedHeadersForRequest, allHeadersForRequest.dictionaryRepresentation())
	}
	
	func test_Get_Vanilla_with_added_headers() {
        let requestURLString = region.hostUrlString()
        let requestURL = URL(string: requestURLString)!

        let updatedHeaders = try! signer.update(headers: ["My-Header1": "value4,value1,value3,value2"],
                                                url: requestURL,
                                                longDate: overridenDate.long,
                                                bodyDigest: Payload.none.hashed(),
                                                region: region)

		let expectedCanonRequest = [
			"GET",
			"/",
			"",
			"host:s3.us-east-1.amazonaws.com",
			"my-header1:value4,value1,value3,value2",
            "x-amz-content-sha256:e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855",
			"x-amz-date:20130524T000000Z",
			"",
			"host;my-header1;x-amz-content-sha256;x-amz-date",
			"e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855"
		].joined(separator: "\n")
		
        let canonRequest = try! signer.createCanonicalRequest(.GET,
                                                              url: requestURL,
                                                              headers: updatedHeaders,
                                                              bodyDigest: Payload.none.hashed())

		XCTAssertEqual(expectedCanonRequest, canonRequest)
		
		let expectedStringToSign = [
			"AWS4-HMAC-SHA256",
			"20130524T000000Z",
			"20130524/us-east-1/s3/aws4_request",
			"349cbfc1c3b792a0a1c113db82e905774d59a3a783b8a4c1635cf46e77b0fd4a"
		].joined(separator: "\n")
		
		let stringToSign = try! signer.createStringToSign(canonRequest,
                                                          dates: overridenDate,
                                                          region: region)
		
		XCTAssertEqual(expectedStringToSign, stringToSign)
		
		let expectedSignature = "b6d537c39971b5174582a0191500f5815737863d2efec1d73fe0b7dd60433006"
		
		let signature = try! signer.createSignature(stringToSign,
                                                    timeStampShort: overridenDate.short,
                                                    region: region)
		
		XCTAssertEqual(expectedSignature, signature)
		
		let expectedAuthHeader = "AWS4-HMAC-SHA256 Credential=AKIAIOSFODNN7EXAMPLE/20130524/us-east-1/s3/aws4_request, SignedHeaders=host;my-header1;x-amz-content-sha256;x-amz-date, Signature=b6d537c39971b5174582a0191500f5815737863d2efec1d73fe0b7dd60433006"
		
        let authHeader = try! signer.generateAuthHeader(.GET, url: requestURL,
                                                        headers: updatedHeaders,
                                                        bodyDigest: Payload.none.hashed(),
                                                        dates: overridenDate,
                                                        region: region)
		
		XCTAssertEqual(expectedAuthHeader, authHeader)
	}
	
	
	func test_Post_With_Param_Vanilla() {
        let requestURLString = region.hostUrlString() + "?Param1=value1"
        let requestURL = URL(string: requestURLString)!

        let updatedHeaders = try! signer.update(headers: [:],
                                                url: requestURL,
                                                longDate: overridenDate.long,
                                                bodyDigest: Payload.none.hashed(),
                                                region: region)

		let expectedCanonRequest = [
			"POST",
			"/",
			"Param1=value1",
			"host:s3.us-east-1.amazonaws.com",
            "x-amz-content-sha256:e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855",
			"x-amz-date:20130524T000000Z",
			"",
			"host;x-amz-content-sha256;x-amz-date",
			"e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855"
		].joined(separator: "\n")
		
		let canonRequest = try! signer.createCanonicalRequest(.POST,
                                                              url: requestURL,
                                                              headers: updatedHeaders,
                                                              bodyDigest: Payload.none.hashed())

		XCTAssertEqual(expectedCanonRequest, canonRequest)
		
		let expectedStringToSign = [
			"AWS4-HMAC-SHA256",
			"20130524T000000Z",
			"20130524/us-east-1/s3/aws4_request",
			"9a8ec1a42be3e36ebd0880ea21ff11dac3c3519c3ab00a23ddb1b1ac4d4163b7"
		].joined(separator: "\n")
		
        let stringToSign = try! signer.createStringToSign(canonRequest, dates: overridenDate, region: region)
		
		XCTAssertEqual(expectedStringToSign, stringToSign)
		
		let expectedSignature = "ea870aa535725edbb806253d7eaac9b0c38cdb256efc42c18739a2e8c14bc2ee"
		
		let signature = try! signer.createSignature(stringToSign, timeStampShort: overridenDate.short, region: region)
		
		XCTAssertEqual(expectedSignature, signature)
		
		let expectedAuthHeader = "AWS4-HMAC-SHA256 Credential=AKIAIOSFODNN7EXAMPLE/20130524/us-east-1/s3/aws4_request, SignedHeaders=host;x-amz-content-sha256;x-amz-date, Signature=ea870aa535725edbb806253d7eaac9b0c38cdb256efc42c18739a2e8c14bc2ee"
		
		let authHeader = try! signer.generateAuthHeader(.POST,
                                                        url: requestURL,
                                                        headers: updatedHeaders,
                                                        bodyDigest: Payload.none.hashed(),
                                                        dates: overridenDate,
                                                        region: region)
		
		XCTAssertEqual(expectedAuthHeader, authHeader)
		
		let allExpectedHeadersForRequest = [
			"host": "s3.us-east-1.amazonaws.com",
            "x-amz-date": "20130524T000000Z",
            "x-amz-content-sha256": "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855",
			"authorization": "AWS4-HMAC-SHA256 Credential=AKIAIOSFODNN7EXAMPLE/20130524/us-east-1/s3/aws4_request, SignedHeaders=host;x-amz-content-sha256;x-amz-date, Signature=ea870aa535725edbb806253d7eaac9b0c38cdb256efc42c18739a2e8c14bc2ee"
		]

        let allHeadersForRequest = try! signer.headers(for: .POST, urlString: requestURLString, payload: .none, dates: overridenDate)

		XCTAssertEqual(allExpectedHeadersForRequest, allHeadersForRequest.dictionaryRepresentation())
	}
}

extension HTTPHeaders {
    func dictionaryRepresentation() -> [String: String] {
        var result = [String: String]()
        self.forEach { (header) in
            result[header.name] = header.value
        }
        return result
    }
}


