import Foundation
import Crypto
import Core

public class S3SignerAWS  {
	
	/// AWS Access Key
	private let accessKey: String
	
	/// The region where S3 bucket is located.
	public let region: Region
	
	/// AWS Secret Key
	private let secretKey: String
	
	/// AWS Security Token. Used to validate temporary credentials, such as those from an EC2 Instance's IAM role
	private let securityToken : String? //
	
	/// The service used in calculating the signature. Currently limited to s3, possible expansion to other services after testing.
	internal var service: String {
		return "s3"
	}
	
	/// Initializes a signer which works for either permanent credentials or temporary secrets
	///
	/// - Parameters:
	///   - accessKey: AWS Access Key
	///   - secretKey: AWS Secret Key
	///   - region: Which AWS region to sign against
	///   - securityToken: Optional token used only with temporary credentials
	public init(accessKey: String,
	            secretKey: String,
	            region: Region,
	            securityToken: String? = nil)
	{
		self.accessKey = accessKey
		self.secretKey = secretKey
		self.region = region
		self.securityToken = securityToken
	}
	
	/// Generate a V4 auth header for aws Requests.
	///
	/// - Parameters:
	///   - httpMethod: HTTP Method (GET, HEAD, PUT, POST, DELETE)
	///   - urlString: Full URL String. Left for ability to customize whether a virtual hosted-style request i.e. "https://exampleBucket.s3.amazonaws.com" vs path-style request i.e. "https://s3.amazonaws.com/exampleBucket". Make sure to include url scheme i.e. https:// or signature will not be calculated properly.
	///   - headers: Any additional headers you want incuded in the signature. All the required headers are created automatically.
	///   - payload: The payload being sent with request
	/// - Returns: The required headers that need to be sent with request. Host, X-Amz-Date, Authorization
	///			- If PUT request, Content-Length
	///			- if PUT and pathExtension is available, Content-Type
	///			- if PUT and not unsigned, Content-md5
	/// - Throws: S3SignerError
	public func authHeaderV4(
		httpMethod: HTTPMethod,
		urlString: String,
		headers: [String: String] = [:],
		payload: Payload)
		throws -> [String:String]
	{
			guard let url = URL(string: urlString) else {
				throw S3SignerError.badURL
			}
			
			let dates = getDates(date: Date())
			
			let bodyDigest = try payload.hashed()
			
			var updatedHeaders = updateHeaders(
				headers: headers,
				url: url,
				longDate: dates.long,
				bodyDigest: bodyDigest)
			
			if httpMethod == .put && payload.isBytes {
				updatedHeaders["content-md5"] = try Hash.make(.md5, payload.bytes).base64Encoded.makeString()
			}
			
			updatedHeaders["Authorization"] = try generateAuthHeader(
				httpMethod: httpMethod,
				url: url,
				headers: updatedHeaders,
				bodyDigest: bodyDigest,
				dates: dates)
			
			if httpMethod == .put {
				updatedHeaders["Content-Length"] = payload.size()
				
				if url.pathExtension != "" {
					updatedHeaders["Content-Type"] = url.pathExtension
				}
			}
			
			if payload.isUnsigned {
				updatedHeaders["x-amz-content-sha256"] = bodyDigest
			}
			
			return updatedHeaders
	}
	
	/// Generate a V4 pre-signed URL
	///
	/// - Parameters:
	///   - httpMethod: The method of request.
	///   - urlString: Full URL String. Left for ability to customize whether a virtual hosted-style request i.e. "https://exampleBucket.s3.amazonaws.com" vs path-style request i.e. "https://s3.amazonaws.com/exampleBucket". Make sure to include url scheme i.e. https:// or signature will not be calculated properly.
	///   - expiration: How long the URL is valid.
	///   - headers: Any additional headers to be included with signature calculation.
	/// - Returns: Pre-signed URL string.
	/// - Throws: S3SignerError
	public func presignedURLV4(
		httpMethod: HTTPMethod,
		urlString: String,
		expiration: TimeFromNow,
		headers: [String:String])
		throws -> String
	{
			guard let url = URL(string: urlString) else {
				throw S3SignerError.badURL
			}
			
			let dates = getDates(date: Date())
			
			var updatedHeaders = headers
			
			updatedHeaders["Host"] = url.host ?? region.host
			
			let (canonRequest, fullURL) = try presignedURLCanonRequest(httpMethod: httpMethod, dates: dates, expiration: expiration, url: url, headers: updatedHeaders)
			
			let stringToSign = try createStringToSign(canonicalRequest: canonRequest, dates: dates)
			
			let signature = try createSignature(stringToSign: stringToSign, timeStampShort: dates.short)
			
			let presignedURL = fullURL.absoluteString.appending("&X-Amz-Signature=\(signature)")
	
			return presignedURL
	}
	
	internal func canonicalHeaders(
		headers: [String: String])
		-> String
	{
		 #if swift(>=4)
			let headerList = Array(headers.keys)
			.map { "\($0.lowercased()):\(headers[$0]!)" }
			.filter { $0 != "authorization" }
			.sorted(by: { $0.localizedCompare($1) == ComparisonResult.orderedAscending })
			//.sorted { $0.0.localizedCompare($0.1) == ComparisonResult.orderedAscending }
			.joined(separator: "\n")
			.appending("\n")
			
			return headerList
			#else
			
			let headerList = Array(headers.keys)
				.map { "\($0.lowercased()):\(headers[$0]!)" }
				.filter { $0 != "authorization" }
				.sorted { $0.0.localizedCompare($0.1) == ComparisonResult.orderedAscending }
				.joined(separator: "\n")
				.appending("\n")
			
			return headerList
			
			#endif
	}
	
	internal func createCanonicalRequest(
		httpMethod: HTTPMethod,
		url: URL,
		headers: [String: String],
		bodyDigest: String)
		throws -> String
	{
			return try [
				httpMethod.rawValue,
				path(url: url),
				query(url: url),
				canonicalHeaders(headers: headers),
				signedHeaders(headers: headers),
				bodyDigest
				].joined(separator: "\n")
	}
	
	/// Create signature
	///
	/// - Parameters:
	///   - stringToSign: String to sign.
	///   - timeStampShort: Short timestamp.
	/// - Returns: Signature.
	/// - Throws: HMAC error.
	internal func createSignature(
		stringToSign: String,
		timeStampShort: String)
		throws -> String
	{
		let dateKey = try HMAC.make(.sha256, timeStampShort.bytes, key: "AWS4\(secretKey)".bytes)
		let dateRegionKey = try HMAC.make(.sha256, region.rawValue.bytes, key: dateKey)
		let dateRegionServiceKey = try HMAC.make(.sha256, service.bytes, key: dateRegionKey)
		let signingKey = try HMAC.make(.sha256, "aws4_request".bytes, key: dateRegionServiceKey)
		let signature = try HMAC.make(.sha256, stringToSign.bytes, key: signingKey).hexString
		return signature
	}

	/// Create the String To Sign portion of signature.
	///
	/// - Parameters:
	///   - canonicalRequest: The canonical request used.
	///   - dates: The dates object containing short and long timestamps of request.
	/// - Returns: String to sign.
	/// - Throws: If hashing canonical request fails.
	internal func createStringToSign(
		canonicalRequest: String,
		dates: Dates)
		throws -> String
	{
		let canonRequestHash = try Hash.make(.sha256, canonicalRequest.bytes).hexString
		return ["AWS4-HMAC-SHA256",
		        dates.long,
		        credentialScope(timeStampShort: dates.short),
		        canonRequestHash]
			.joined(separator: "\n")
	}
	
	/// Credential scope
	///
	/// - Parameter timeStampShort: Short timestamp.
	/// - Returns: Credential Scope.
	private func credentialScope(
		timeStampShort: String)
		-> String
	{
		return  [
			timeStampShort,
			region.rawValue,
			service, "aws4_request"
			].joined(separator: "/")
	}
	
	/// Generate Auth Header for V4 Authorization Header request.
	///
	/// - Parameters:
	///   - httpMethod: The HTTPMethod of request.
	///   - url: The URL of the request.
	///   - headers: All headers used in signature calcuation.
	///   - bodyDigest: The hashed payload of request.
	///   - dates: The short and long timestamps of time of request.
	/// - Returns: Authorization header value.
	/// - Throws: S3SignerError
	internal func generateAuthHeader(
		httpMethod: HTTPMethod,
		url: URL,
		headers: [String:String],
		bodyDigest: String,
		dates: Dates)
		throws -> String
	{
			let canonicalRequestHex = try createCanonicalRequest(httpMethod: httpMethod, url: url, headers: headers, bodyDigest: bodyDigest)
			let stringToSign = try createStringToSign(canonicalRequest: canonicalRequestHex, dates: dates)
			let signature = try createSignature(stringToSign: stringToSign, timeStampShort: dates.short)
			let authHeader = "AWS4-HMAC-SHA256 Credential=\(accessKey)/\(credentialScope(timeStampShort: dates.short)), SignedHeaders=\(signedHeaders(headers: headers)), Signature=\(signature)"
			
			return authHeader
	}
	
	/// Instantiate Dates object containing the required date formats needed for signature calculation.
	///
	/// - Parameter date: The date of request.
	/// - Returns: Dates object.
	internal func getDates(date: Date) -> Dates {
		return Dates(date: date)
	}
	
	/// The percent encoded path of request URL.
	///
	/// - Parameter url: The URL of request.
	/// - Returns: Percent encoded path if not empty, or "/".
	/// - Throws: Encoding error.
	private func path(url: URL) throws -> String {
		return try !url.path.isEmpty ? url.path.percentEncode(allowing: Byte.awsPathAllowed) : "/"
	}
	
	/// The canonical request for Presigned URL requests.
	///
	/// - Parameters:
	///   - httpMethod: HTTPMethod of request.
	///   - dates: Dates formatted for request.
	///   - expiration: The period of time before URL expires.
	///   - url: The URL of the request.
	///   - headers: Headers used to sign and add to presigned URL.
	/// - Returns: Canonical request for pre-signed URL.
	/// - Throws: S3SignerError
	internal func presignedURLCanonRequest(
		httpMethod: HTTPMethod,
		dates: Dates,
		expiration: TimeFromNow,
		url: URL,
		headers: [String: String])
		throws -> (String, URL)
	{
		let credScope = try credentialScope(timeStampShort: dates.short).percentEncode(allowing: Byte.awsQueryAllowed)
		let signHeaders = try signedHeaders(headers: headers).percentEncode(allowing: Byte.awsQueryAllowed)
		let fullURL = "\(url.absoluteString)?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=\(accessKey)%2F\(credScope)&X-Amz-Date=\(dates.long)&X-Amz-Expires=\(expiration.expiration)&X-Amz-SignedHeaders=\(signHeaders)"
		
		// This should never throw. 
		guard let url = URL(string: fullURL) else {
			throw S3SignerError.badURL
		}

		return try (
			[
			httpMethod.rawValue,
			path(url: url),
			query(url: url),
			canonicalHeaders(headers: headers),
			signedHeaders(headers: headers),
			"UNSIGNED-PAYLOAD"
			].joined(separator: "\n"),
			url)
	}
	
	/// Encode and sort queryItems.
	///
	/// - Parameter url: The URL for request containing the possible queryItems.
	/// - Returns: Encoded and sorted(By Key) queryItem String.
	/// - Throws: Encoding Error
	internal func query(url: URL)throws -> String {
		if let queryItems = URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems {
			let encodedItems = try queryItems.map { try "\($0.name.percentEncode(allowing: Byte.awsQueryAllowed))=\($0.value?.percentEncode(allowing: Byte.awsQueryAllowed) ?? "")"}
			return encodedItems.sorted().joined(separator: "&")
		}
		return ""
	}
	
	/// Signed headers
	///
	/// - Parameter headers: Headers to sign.
	/// - Returns: Signed headers.
	private func signedHeaders(headers: [String: String]) -> String {
		let headerList = Array(headers.keys).map { $0.lowercased() }.filter { $0.lowercased() != "authorization" }.sorted().joined(separator: ";")
		return headerList
	}
	
	/// Add the required headers to a V4 authorization header request.
	///
	/// - Parameters:
	///   - headers: Original headers to add the additional required headers to.
	///   - url: The URL of the request.
	///   - longDate: The formatted ISO date.
	///   - bodyDigest: The payload hash of request.
	/// - Returns: Updated headers with additional required headers.
	internal func updateHeaders(
		headers: [String:String],
		url: URL,
		longDate: String,
		bodyDigest: String)
		-> [String:String]
	{
			var updatedHeaders = headers
			updatedHeaders["X-Amz-Date"] = longDate
			updatedHeaders["Host"] = url.host ?? region.host
			
			if bodyDigest != "UNSIGNED-PAYLOAD" && service == "s3" {
				updatedHeaders["x-amz-content-sha256"] = bodyDigest
			}
			// According to http://docs.aws.amazon.com/IAM/latest/UserGuide/id_credentials_temp_use-resources.html#RequestWithSTS
			if let token = securityToken {
				updatedHeaders["X-Amz-Security-Token"] = token
			}
			return updatedHeaders
	}
}
