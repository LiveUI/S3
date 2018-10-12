@testable import S3Signer
import XCTest

class S3Tests: BaseTestCase {
	
	static var allTests = [
		("test_Get_Object", test_Get_Object),
		("test_Put_Object", test_Put_Object),
		("test_Get_bucket_lifecycle", test_Get_bucket_lifecycle),
		("test_Get_bucket_list_object", test_Get_bucket_list_object),
		("test_Presigned_URL_V4", test_Presigned_URL_V4)
	]
	
	// S3 example signature calcuations
	// https://docs.aws.amazon.com/AmazonS3/latest/API/sig-v4-header-based-auth.html#example-signature-calculations

    func test_Get_Object() {
		let requestURL = URL(string: "https://examplebucket.s3.amazonaws.com/test.txt")!
        let updatedHeaders = signer.update(headers: ["Range": "bytes=0-9"], url: requestURL, longDate: overridenDate.long, bodyDigest: try! Payload.none.hashed(), region: region)
		
		let expectedCanonRequest = [
		"GET",
		"/test.txt",
		"",
		"host:examplebucket.s3.amazonaws.com",
		"range:bytes=0-9",
		"x-amz-content-sha256:e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855",
		"x-amz-date:20130524T000000Z",
		"",
		"host;range;x-amz-content-sha256;x-amz-date",
		"e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855"
		].joined(separator: "\n")
		
		let canonRequest = try! signer.createCanonicalRequest(.GET, url: requestURL, headers: updatedHeaders, bodyDigest: Payload.none.hashed())
		
        XCTAssertEqual(expectedCanonRequest, canonRequest)

		let expectedStringToSign = [
			"AWS4-HMAC-SHA256",
			"20130524T000000Z",
			"20130524/us-east-1/s3/aws4_request",
			"7344ae5b7ee6c3e7e6b0fe0640412a37625d1fbfff95c48bbb2dc43964946972"
		].joined(separator: "\n")
		
		let stringToSign = try! signer.createStringToSign(canonRequest, dates: overridenDate, region: region)
		
		XCTAssertEqual(expectedStringToSign, stringToSign)
		
		let expectedSignature = "f0e8bdb87c964420e857bd35b5d6ed310bd44f0170aba48dd91039c6036bdb41"
		
		let signature = try! signer.createSignature(stringToSign, timeStampShort: overridenDate.short, region: region)
		
		XCTAssertEqual(expectedSignature, signature)
		
		let expectedAuthHeader = "AWS4-HMAC-SHA256 Credential=AKIAIOSFODNN7EXAMPLE/20130524/us-east-1/s3/aws4_request, SignedHeaders=host;range;x-amz-content-sha256;x-amz-date, Signature=f0e8bdb87c964420e857bd35b5d6ed310bd44f0170aba48dd91039c6036bdb41"
		
		let authHeader = try! signer.generateAuthHeader(.GET, url: requestURL, headers: updatedHeaders, bodyDigest: Payload.none.hashed(), dates: overridenDate, region: region)
		
		XCTAssertEqual(expectedAuthHeader, authHeader)
	}
	
	func test_Put_Object() {
        guard let requestURL = URL(string: "https://examplebucket.s3.amazonaws.com/test$file.text"),
            let bytes = "Welcome to Amazon S3.".data(using: .utf8) else {
                XCTFail("Could not intialize request/data")
                return
        }

		let payload = try! Payload.bytes(bytes).hashed()

		let updatedHeaders = signer.update(headers: ["x-amz-storage-class": "REDUCED_REDUNDANCY", "Date": "Fri, 24 May 2013 00:00:00 GMT"], url: requestURL, longDate: overridenDate.long, bodyDigest: payload, region: region)
		
		let expectedCanonRequest = [
			"PUT",
			"/test%24file.text",
			"",
			"date:Fri, 24 May 2013 00:00:00 GMT",
			"host:examplebucket.s3.amazonaws.com",
			"x-amz-content-sha256:44ce7dd67c959e0d3524ffac1771dfbba87d2b6b4b4e99e42034a8b803f8b072",
			"x-amz-date:20130524T000000Z",
			"x-amz-storage-class:REDUCED_REDUNDANCY",
			"",
			"date;host;x-amz-content-sha256;x-amz-date;x-amz-storage-class",
			"44ce7dd67c959e0d3524ffac1771dfbba87d2b6b4b4e99e42034a8b803f8b072"
		].joined(separator: "\n")
		
		let canonRequest = try! signer.createCanonicalRequest(.PUT, url: requestURL, headers: updatedHeaders, bodyDigest: payload)
		
		XCTAssertEqual(expectedCanonRequest, canonRequest)
		
		let expectedStringToSign = [
			"AWS4-HMAC-SHA256",
			"20130524T000000Z",
			"20130524/us-east-1/s3/aws4_request",
			"9e0e90d9c76de8fa5b200d8c849cd5b8dc7a3be3951ddb7f6a76b4158342019d"
		].joined(separator: "\n")
		
		let stringToSign = try! signer.createStringToSign(canonRequest, dates: overridenDate, region: region)
		
		XCTAssertEqual(expectedStringToSign, stringToSign)
		
		let expectedSignature = "98ad721746da40c64f1a55b78f14c238d841ea1380cd77a1b5971af0ece108bd"
		
		let signature = try! signer.createSignature(stringToSign, timeStampShort: overridenDate.short, region: region)
		
		XCTAssertEqual(expectedSignature, signature)
		
		let expectedAuthHeader = "AWS4-HMAC-SHA256 Credential=AKIAIOSFODNN7EXAMPLE/20130524/us-east-1/s3/aws4_request, SignedHeaders=date;host;x-amz-content-sha256;x-amz-date;x-amz-storage-class, Signature=98ad721746da40c64f1a55b78f14c238d841ea1380cd77a1b5971af0ece108bd"
		
		let authHeader = try! signer.generateAuthHeader(.PUT, url: requestURL, headers: updatedHeaders, bodyDigest: payload, dates: overridenDate, region: region)
		
		XCTAssertEqual(expectedAuthHeader, authHeader)
	}
	
	func test_Get_bucket_lifecycle() {
		let requestURL = URL(string: "https://examplebucket.s3.amazonaws.com?lifecycle")!
		let payload = try! Payload.none.hashed()
		let updatedHeaders = signer.update(headers: [:], url: requestURL, longDate: overridenDate.long, bodyDigest: payload, region: region)
		
		let expectedCanonRequest = [
			"GET",
			"/",
			"lifecycle=",
			"host:examplebucket.s3.amazonaws.com",
			"x-amz-content-sha256:e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855",
			"x-amz-date:20130524T000000Z",
			"",
			"host;x-amz-content-sha256;x-amz-date",
			"e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855"
		].joined(separator: "\n")
		
		let canonRequest = try! signer.createCanonicalRequest(.GET, url: requestURL, headers: updatedHeaders, bodyDigest: payload)
		
		XCTAssertEqual(expectedCanonRequest, canonRequest)
		
		let expectedAuthHeader = "AWS4-HMAC-SHA256 Credential=AKIAIOSFODNN7EXAMPLE/20130524/us-east-1/s3/aws4_request, SignedHeaders=host;x-amz-content-sha256;x-amz-date, Signature=fea454ca298b7da1c68078a5d1bdbfbbe0d65c699e0f91ac7a200a0136783543"
		
		let authHeader = try! signer.generateAuthHeader(.GET, url: requestURL, headers: updatedHeaders, bodyDigest: payload, dates: overridenDate, region: region)
		
		XCTAssertEqual(expectedAuthHeader, authHeader)
	}
	
	func test_Get_bucket_list_object() {
		let requestURL = URL(string: "https://examplebucket.s3.amazonaws.com/?max-keys=2&prefix=J")!
		let payload = try! Payload.none.hashed()
		let updatedHeaders = signer.update(headers: [:], url: requestURL, longDate: overridenDate.long, bodyDigest: payload, region: region)
		
		let expectedCanonRequest = [
			"GET",
			"/",
			"max-keys=2&prefix=J",
			"host:examplebucket.s3.amazonaws.com",
			"x-amz-content-sha256:e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855",
			"x-amz-date:20130524T000000Z",
			"",
			"host;x-amz-content-sha256;x-amz-date",
			"e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855"
		].joined(separator: "\n")
		
		let canonRequest = try! signer.createCanonicalRequest(.GET, url: requestURL, headers: updatedHeaders, bodyDigest: payload)
		
		XCTAssertEqual(expectedCanonRequest, canonRequest)
		
		let expectedAuthHeader = "AWS4-HMAC-SHA256 Credential=AKIAIOSFODNN7EXAMPLE/20130524/us-east-1/s3/aws4_request, SignedHeaders=host;x-amz-content-sha256;x-amz-date, Signature=34b48302e7b5fa45bde8084f4b7868a86f0a534bc59db6670ed5711ef69dc6f7"
		
		let authHeader = try! signer.generateAuthHeader(.GET, url: requestURL, headers: updatedHeaders, bodyDigest: payload, dates: overridenDate, region: region)
		
		XCTAssertEqual(expectedAuthHeader, authHeader)
	}
	
	// Taken from https://docs.aws.amazon.com/AmazonS3/latest/API/sigv4-query-string-auth.html
	func test_Presigned_URL_V4() {
		let requestURL = URL(string: "https://examplebucket.s3.amazonaws.com/test.txt")!
		
		let expectedCanonRequest = [
			"GET",
			"/test.txt",
			"x-amz-algorithm=AWS4-HMAC-SHA256&x-amz-credential=AKIAIOSFODNN7EXAMPLE%2F20130524%2Fus-east-1%2Fs3%2Faws4_request&x-amz-date=20130524T000000Z&x-amz-expires=86400&x-amz-signedheaders=host",
			"host:examplebucket.s3.amazonaws.com",
			"",
			"host",
			"UNSIGNED-PAYLOAD"
			].joined(separator: "\n")

        let (canonRequest, _) = try! signer.presignedURLCanonRequest(.GET, dates: overridenDate, expiration: Expiration.custom(86400), url: requestURL, region: region, headers: ["Host": requestURL.host ?? Region.usEast1.host])
		
		XCTAssertEqual(expectedCanonRequest, canonRequest)
		
		let expectedStringToSign = [
			"AWS4-HMAC-SHA256",
			"20130524T000000Z",
			"20130524/us-east-1/s3/aws4_request",
			"414cf5ed57126f2233fac1f7b5e5e4b8dcf58040010cb69d21f126d353d13df7"
		].joined(separator: "\n")
		
		let stringToSign = try! signer.createStringToSign(canonRequest, dates: overridenDate, region: region)

        NSLog("expectedStringToSign: \(expectedStringToSign)")
        NSLog("stringToSign: \(stringToSign)")
		XCTAssertEqual(expectedStringToSign, stringToSign)
		
		let expectedSignature = "17594f59285415a5be4debfcf5227a2d78b7c2634442b7ab816cace9333ec989"
		
		let signature = try! signer.createSignature(stringToSign, timeStampShort: overridenDate.short, region: region)
		
		XCTAssertEqual(expectedSignature, signature)

		
		let expectedURLString = "https://examplebucket.s3.amazonaws.com/test.txt?x-amz-algorithm=AWS4-HMAC-SHA256&x-amz-credential=AKIAIOSFODNN7EXAMPLE%2F20130524%2Fus-east-1%2Fs3%2Faws4_request&x-amz-date=20130524T000000Z&x-amz-expires=86400&x-amz-signedheaders=host&x-amz-signature=17594f59285415a5be4debfcf5227a2d78b7c2634442b7ab816cace9333ec989"

        let presignedURL = try! signer.presignedURL(for: .GET, url: requestURL, expiration: Expiration.custom(86400), region: region, headers: [:], dates: overridenDate)

		XCTAssertEqual(expectedURLString, presignedURL?.absoluteString)
	}
}
