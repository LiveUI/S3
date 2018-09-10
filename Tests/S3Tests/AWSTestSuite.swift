@testable import S3Signer
@testable import S3
import XCTest

class AWSTestSuite: XCTestCase {
	
	static var allTests = [
		("test_Get_Vanilla", test_Get_Vanilla),
		("test_Get_Vanilla_with_added_headers", test_Get_Vanilla_with_added_headers),
		("test_Post_With_Param_Vanilla", test_Post_With_Param_Vanilla)
	]
    
    //Testing Data from AWS Test Suite
	// https://docs.aws.amazon.com/general/latest/gr/signature-v4-test-suite.html
    
    let testSuiteAccessKey = "AKIDEXAMPLE"
    let testSuiteSecretKey = "wJalrXUtnFEMI/K7MDENG+bPxRfiCYEXAMPLEKEY"
	
    var signer: S3Signer!
    var overridenDate: Dates!
    var region: Region!

    override func setUp() {
        super.setUp()
        region = Region.usEast1
        signer = try! S3Signer(S3Signer.Config(accessKey: testSuiteAccessKey, secretKey: testSuiteSecretKey, region: region))
        overridenDate = Dates(Date(timeIntervalSince1970: (60*60*24) * 366 * 45))
    }
	
	func test_Get_Vanilla() {
        let requestURLString = region.hostUrlString()
        let requestURL = URL(string: requestURLString)!
        let updatedHeaders = try! signer.headers(for: .GET, urlString: requestURLString, region: region, headers: [:], payload: Payload.none)
		let expectedCanonRequest = [
			"GET",
			"/",
			"",
			"host:\(region.host)",
			"x-amz-date:20150830T123600Z",
			"",
			"host;x-amz-date",
			"e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855"]
			.joined(separator: "\n")
		
        let canonRequest = try! signer.createCanonicalRequest(.GET,
                                                              url: requestURL,
                                                              headers: updatedHeaders.toDictionary(),
                                                              bodyDigest: Payload.none.hashed())

		XCTAssertEqual(expectedCanonRequest, canonRequest)
		
		let expectedStringToSign = [
			"AWS4-HMAC-SHA256",
			"20150830T123600Z",
			"20150830/us-east-1/service/aws4_request",
			"bb579772317eb040ac9ed261061d46c1f17a8133879d6129b6e1c25292927e63"
			].joined(separator: "\n")
		
        let stringToSign = try! signer.createStringToSign(canonRequest,
                                                          dates: overridenDate,
                                                          region: region)

		XCTAssertEqual(expectedStringToSign, stringToSign)
		
		let expectedSignature = "5fa00fa31553b73ebf1942676e86291e8372ff2a2260956d9b8aae1d763fbf31"
        let signature = try! signer.createSignature(stringToSign,
                                                    timeStampShort: overridenDate.short,
                                                    region: region)
		
		XCTAssertEqual(expectedSignature, signature)
		
		let expectedAuthHeader = "AWS4-HMAC-SHA256 Credential=AKIDEXAMPLE/20150830/us-east-1/service/aws4_request, SignedHeaders=host;x-amz-date, Signature=5fa00fa31553b73ebf1942676e86291e8372ff2a2260956d9b8aae1d763fbf31"
		
        let authHeader = try! signer.generateAuthHeader(.GET,
                                                        url: requestURL,
                                                        headers: updatedHeaders.toDictionary(),
                                                        bodyDigest: Payload.none.hashed(),
                                                        dates: overridenDate,
                                                        region: region)
		
		XCTAssertEqual(expectedAuthHeader, authHeader)
		
		let allExpectedHeadersForRequest = [
			"Host": "example.amazonaws.com",
			"X-Amz-Date": "20150830T123600Z",
			"Authorization": "AWS4-HMAC-SHA256 Credential=AKIDEXAMPLE/20150830/us-east-1/service/aws4_request, SignedHeaders=host;x-amz-date, Signature=5fa00fa31553b73ebf1942676e86291e8372ff2a2260956d9b8aae1d763fbf31"
		]

        let allHeadersForRequest = try! signer.update(headers: [:],
                                                      url: requestURL,
                                                      longDate: overridenDate.long,
                                                      bodyDigest: Payload.none.hashed(),
                                                      region: region)
//        let allHeadersForRequest = try! signer.authHeaderV4(httpMethod: .get, urlString: requestURL.absoluteString, payload: .none)

		XCTAssertEqual(allExpectedHeadersForRequest, allHeadersForRequest)
	}
	
	func test_Get_Vanilla_with_added_headers() {
        let requestURLString = region.hostUrlString()
        let requestURL = URL(string: requestURLString)!

        let updatedHeaders = try! signer.headers(for: .GET,
                                                 urlString: requestURLString,
                                                 region: region,
                                                 headers: ["My-Header1": "value4,value1,value3,value2"],
                                                 payload: Payload.none)

//        let updatedHeaders = try! signer.updateHeaders(headers: [
//                "My-Header1": "value4,value1,value3,value2"
//            ], url: requestURL, longDate: overridenDate.long, bodyDigest: Payload.none.hashed())

		let expectedCanonRequest = [
			"GET",
			"/",
			"",
			"host:example.amazonaws.com",
			"my-header1:value4,value1,value3,value2",
			"x-amz-date:20150830T123600Z",
			"",
			"host;my-header1;x-amz-date",
			"e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855"
		].joined(separator: "\n")
		
        let canonRequest = try! signer.createCanonicalRequest(.GET,
                                                              url: requestURL,
                                                              headers: updatedHeaders.toDictionary(),
                                                              bodyDigest: Payload.none.hashed())

		XCTAssertEqual(expectedCanonRequest, canonRequest)
		
		let expectedStringToSign = [
			"AWS4-HMAC-SHA256",
			"20150830T123600Z",
			"20150830/us-east-1/service/aws4_request",
			"31ce73cd3f3d9f66977ad3dd957dc47af14df92fcd8509f59b349e9137c58b86"
		].joined(separator: "\n")
		
		let stringToSign = try! signer.createStringToSign(canonRequest,
                                                          dates: overridenDate,
                                                          region: region)
		
		XCTAssertEqual(expectedStringToSign, stringToSign)
		
		let expectedSignature = "08c7e5a9acfcfeb3ab6b2185e75ce8b1deb5e634ec47601a50643f830c755c01"
		
		let signature = try! signer.createSignature(stringToSign,
                                                    timeStampShort: overridenDate.short,
                                                    region: region)
		
		XCTAssertEqual(expectedSignature, signature)
		
		let expectedAuthHeader = "AWS4-HMAC-SHA256 Credential=AKIDEXAMPLE/20150830/us-east-1/service/aws4_request, SignedHeaders=host;my-header1;x-amz-date, Signature=08c7e5a9acfcfeb3ab6b2185e75ce8b1deb5e634ec47601a50643f830c755c01"
		
        let authHeader = try! signer.generateAuthHeader(.GET, url: requestURL,
                                                        headers: updatedHeaders.toDictionary(),
                                                        bodyDigest: Payload.none.hashed(),
                                                        dates: overridenDate,
                                                        region: region)
		
		XCTAssertEqual(expectedAuthHeader, authHeader)
	}
	
	
	func test_Post_With_Param_Vanilla() {
        let requestURLString = region.hostUrlString() + "?Param1=value1"
        let requestURL = URL(string: requestURLString)!

        let updatedHeaders = try! signer.headers(for: .GET,
                                                 urlString: requestURLString,
                                                 region: region,
                                                 headers: [:],
                                                 payload: Payload.none)
//        let updatedHeaders = try! signer.updateHeaders(headers: [:], url: requestURL, longDate: overridenDate.long, bodyDigest: Payload.none.hashed())
		let expectedCanonRequest = [
			"POST",
			"/",
			"Param1=value1",
			"host:example.amazonaws.com",
			"x-amz-date:20150830T123600Z",
			"",
			"host;x-amz-date",
			"e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855"
		].joined(separator: "\n")
		
		let canonRequest = try! signer.createCanonicalRequest(.POST,
                                                              url: requestURL,
                                                              headers: updatedHeaders.toDictionary(),
                                                              bodyDigest: Payload.none.hashed())

		XCTAssertEqual(expectedCanonRequest, canonRequest)
		
		let expectedStringToSign = [
			"AWS4-HMAC-SHA256",
			"20150830T123600Z",
			"20150830/us-east-1/service/aws4_request",
			"9d659678c1756bb3113e2ce898845a0a79dbbc57b740555917687f1b3340fbbd"
		].joined(separator: "\n")
		
        let stringToSign = try! signer.createStringToSign(canonRequest, dates: overridenDate, region: region)
		
		XCTAssertEqual(expectedStringToSign, stringToSign)
		
		let expectedSignature = "28038455d6de14eafc1f9222cf5aa6f1a96197d7deb8263271d420d138af7f11"
		
		let signature = try! signer.createSignature(stringToSign, timeStampShort: overridenDate.short, region: region)
		
		XCTAssertEqual(expectedSignature, signature)
		
		let expectedAuthHeader = "AWS4-HMAC-SHA256 Credential=AKIDEXAMPLE/20150830/us-east-1/service/aws4_request, SignedHeaders=host;x-amz-date, Signature=28038455d6de14eafc1f9222cf5aa6f1a96197d7deb8263271d420d138af7f11"
		
		let authHeader = try! signer.generateAuthHeader(.POST,
                                                        url: requestURL,
                                                        headers: updatedHeaders.toDictionary(),
                                                        bodyDigest: Payload.none.hashed(),
                                                        dates: overridenDate,
                                                        region: region)
		
		XCTAssertEqual(expectedAuthHeader, authHeader)
		
		let allExpectedHeadersForRequest = [
			"Host": "example.amazonaws.com",
			"X-Amz-Date": "20150830T123600Z",
			"Authorization": "AWS4-HMAC-SHA256 Credential=AKIDEXAMPLE/20150830/us-east-1/service/aws4_request, SignedHeaders=host;x-amz-date, Signature=28038455d6de14eafc1f9222cf5aa6f1a96197d7deb8263271d420d138af7f11"
		]

        let allHeadersForRequest = try! signer.update(headers: [:],
                                                      url: requestURL,
                                                      longDate: overridenDate.long,
                                                      bodyDigest: Payload.none.hashed(),
                                                      region: region)

//        let allHeadersForRequest = try! signer.authHeaderV4(httpMethod: .post, urlString: requestURL.absoluteString, payload: .none)

		XCTAssertEqual(allExpectedHeadersForRequest, allHeadersForRequest)
	}
}

extension HTTPHeaders {
    func toDictionary() -> [String: String] {
        var result = [String: String]()
        self.forEach { (header) in
            result[header.name] = header.value
        }
        return result
    }
}


