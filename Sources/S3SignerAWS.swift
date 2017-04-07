import Foundation
import Crypto
import Core

public class S3SignerAWS  {
    private let accessKey: String
    private let secretKey: String
    private let securityToken : String? // Used to validate temporary credentials, such as those from an EC2 Instance's IAM role
    private let _region: Region
    private let dateFormatter: DateFormatter
    
    public var region: Region {
        get {
           return self._region
        }
    }

    /// Initializes a signer which works for either permanent credentials or temporary secrets
    ///
    /// - Parameters:
    ///   - accessKey: Main token to identify the credential
    ///   - secretKey: Password to validate access
    ///   - region: Which AWS region to sign against
    ///   - securityToken: Optional token used only with temporary credentials
    public init(accessKey: String, secretKey: String, region: Region, securityToken: String? = nil) {
        self.accessKey = accessKey
        self.secretKey = secretKey
        self._region = region
        self.securityToken = securityToken
        self.dateFormatter = DateFormatter()
    }

    public func authHeaderV4(httpMethod: HTTPMethod, urlString: String, pathPercentEncoding: CharacterSet =  CharacterSet.urlPathAllowed, queryPercentEncoding: CharacterSet = CharacterSet.urlQueryAllowed, headers: [String: String], payload: Payload, mimeType: String? = nil) throws -> [String:String] {
        
        guard let url = URL(string: urlString) else { throw S3SignerError.badURL }
        
        let dates = getDates(date: Date())
        
        let bodyDigest = try payload.hashed()
        
        var updatedHeaders = updateHeaders(headers: headers, url: url, longDate: dates.long, bodyDigest: bodyDigest)
        
        if httpMethod == .put {
            if payload.isBytes {
            let MD5Digest = try Hash.make(.md5, payload.bytes).base64Encoded.makeString()
            updatedHeaders["content-md5"] = MD5Digest
            }
        }
        
        let authHeader = try generateAuthHeader(httpMethod: httpMethod, url: url, pathEncoding: pathPercentEncoding, queryEncoding: queryPercentEncoding, headers: updatedHeaders, bodyDigest: bodyDigest, dates: dates)
        
        updatedHeaders["Authorization"] = authHeader
        
        if httpMethod == .put {
            let payloadSize = try payload.isBytes ? payload.bytes.count.description : payload.hashed()
            updatedHeaders["Content-Length"] = payloadSize
         
            if let mimeType = mimeType {
                updatedHeaders["Content-Type"] = mimeType
            }
        }
        if payload.isUnsigned {
            updatedHeaders["x-amz-content-sha256"] = try payload.hashed()
        }
        
        return updatedHeaders
    }
    
    public func presignedURLV4(httpMethod: HTTPMethod, urlString: String, expiration: TimeFromNow, headers: [String:String]) throws -> URLV4Returnable {
        let dates = getDates(date: Date())
        var headersCopy = headers
        headersCopy["Host"] = region.host
        guard let encodedScope = credentialScope(timeStampShort: dates.short).addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else { throw S3SignerError.unableToEncodeCredentialScope }
        let signature = try getPresignedURLSig(httpMethod: httpMethod, urlString: urlString, headers: headersCopy, dates: dates, encodedScope: encodedScope, expiration: expiration)
        
        guard let hostEncodedScope = credentialScope(timeStampShort: dates.short).addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) else { throw S3SignerError.unableToEncodeCredentialScope }
        
        let presignedURL = "\(urlString)?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=\(accessKey)%2F\(hostEncodedScope)&X-Amz-Date=\(dates.long)&X-Amz-Expires=\(expiration.v4Expiration)&X-Amz-SignedHeaders=\(signedHeaders(headers: headersCopy))&X-Amz-Signature=\(signature)"
  
        return URLV4Returnable(headers: headers, urlString: presignedURL)
    }
    
    public func presignedURLV2(urlString: String, expiration: TimeFromNow) throws -> String {
        let expirationTime = expiration.v2Expiration
        
        guard let url = URL(string: urlString) else { throw S3SignerError.badURL }
        guard let stringToSign = ["GET", "", "", "\(expirationTime)", path(url: url)].joined(separator: "\n").data(using: String.Encoding.utf8) else { throw S3SignerError.unableToEncodeStringToSign }
        
        let stringToSignBytes = stringToSign.makeBytes()
        let signature = try HMAC.make(.sha1, stringToSignBytes, key: secretKey.bytes).base64Encoded.makeString().addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)
        guard let sig = signature else { throw  S3SignerError.unableToEncodeSignature }
        
        let finalURLString = "\(urlString)?AWSAccessKeyId=\(accessKey)&Signature=\(sig)&Expires=\(expirationTime)"
        
        return finalURLString
    }
    
    fileprivate func generateAuthHeader(httpMethod: HTTPMethod, url: URL, pathEncoding: CharacterSet, queryEncoding: CharacterSet, headers: [String:String], bodyDigest: String, dates: Dates) throws -> String {
        let canonicalRequestHex = try createCanonicalRequest(httpMethod: httpMethod, url: url, pathEncoding: pathEncoding, queryEncoding: queryEncoding, headers: headers, bodyDigest: bodyDigest)
        let stringToSign = try createStringToSign(canonicalRequest: canonicalRequestHex, timeStampLong: dates.long, timeStampShort: dates.short)
        let signature = try getSignature(stringToSign: stringToSign, timeStampShort: dates.short)
        let authHeader = "AWS4-HMAC-SHA256 Credential=\(accessKey)/\(credentialScope(timeStampShort: dates.short)), SignedHeaders=\(signedHeaders(headers: headers)), Signature=\(signature)"
        
        return authHeader
    }
    
    fileprivate func getPresignedURLSig(httpMethod: HTTPMethod, urlString: String, headers: [String:String], dates: Dates, encodedScope: String, expiration: TimeFromNow) throws -> String {
        let paramURLString = "\(urlString)?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=\(accessKey)/\(encodedScope)&X-Amz-Date=\(dates.long)&X-Amz-Expires=\(expiration.v4Expiration)&X-Amz-SignedHeaders=\(signedHeaders(headers: headers))"
        guard let url = URL(string: paramURLString) else { throw S3SignerError.badURL }
        let canonicalRequest = [httpMethod.rawValue, path(url: url), "\(url.query?.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? "")", canonicalHeaders(headers: headers), signedHeaders(headers: headers), "UNSIGNED-PAYLOAD"].joined(separator: "\n")
        let stringToSign = try createStringToSign(canonicalRequest: canonicalRequest, timeStampLong: dates.long, timeStampShort: dates.short)
        let signature = try getSignature(stringToSign: stringToSign, timeStampShort: dates.short)
        
        return signature
    }

    fileprivate func updateHeaders(headers: [String:String], url: URL,longDate: String, bodyDigest: String) -> [String:String] {
        var headersCopy = headers
        headersCopy["x-amz-date"] = longDate
        headersCopy["host"] = url.host != nil ? url.host! : _region.host
        if bodyDigest != "UNSIGNED-PAYLOAD" {
            headersCopy["x-amz-content-sha256"] = bodyDigest
        }
        // According to http://docs.aws.amazon.com/IAM/latest/UserGuide/id_credentials_temp_use-resources.html#RequestWithSTS
        if let token = securityToken {
            headersCopy["X-Amz-Security-Token"] = token
        }
        return headersCopy
    }

    
    fileprivate func getDates(date: Date) -> Dates {
        let shortDate = timestamp(date: date, shortDate: true)
        let longDate = timestamp(date: date, shortDate: false)
        return Dates(short: shortDate, long: longDate)
    }
    
    fileprivate func path(url: URL) -> String {
        let path = !url.path.isEmpty ? url.path : "/"
        return path
    }
    
    fileprivate func canonicalHeaders(headers: [String: String]) -> String {
        let headerList = Array(headers.keys).sorted { $0.0.localizedCompare($0.1) == ComparisonResult.orderedAscending }.filter { $0.lowercased() != "authorization" }.map { "\($0.lowercased()):\(headers[$0]!)" }.joined(separator: "\n").appending("\n")
        return headerList
    }
    
    fileprivate func signedHeaders(headers: [String: String]) -> String {
        let headerList = Array(headers.keys).map { $0.lowercased() }.filter { $0.lowercased() != "authorization" }.sorted().joined(separator: ";")
        return headerList
    }
    
    fileprivate func createCanonicalRequest(httpMethod: HTTPMethod, url: URL, pathEncoding: CharacterSet, queryEncoding: CharacterSet, headers: [String: String], bodyDigest: String) throws -> String {
        guard let encodedPath = path(url: url).addingPercentEncoding(withAllowedCharacters: pathEncoding) else { throw S3SignerError.unableToEncodeURLPath }
        return [ httpMethod.rawValue, encodedPath, url.query?.addingPercentEncoding(withAllowedCharacters: queryEncoding) ?? "", "\(canonicalHeaders(headers: headers))", signedHeaders(headers: headers), bodyDigest].joined(separator: "\n")
    }
    
    fileprivate func createStringToSign(canonicalRequest: String, timeStampLong: String, timeStampShort: String) throws -> String {
        let canonRequestHash = try Hash.make(.sha256, canonicalRequest.bytes).hexString
        return ["AWS4-HMAC-SHA256", timeStampLong, credentialScope(timeStampShort: timeStampShort), canonRequestHash].joined(separator: "\n")
    }
    
    fileprivate func getSignature(stringToSign: String, timeStampShort: String) throws -> String {
        let dateKey = try HMAC.make(.sha256, timeStampShort.bytes, key: "AWS4\(secretKey)".bytes)
        let dateRegionKey = try HMAC.make(.sha256, region.rawValue.bytes, key: dateKey)
        let dateRegionServiceKey = try HMAC.make(.sha256, "s3".bytes, key: dateRegionKey)
        let signingKey = try HMAC.make(.sha256, "aws4_request".bytes, key: dateRegionServiceKey)
        let signature = try HMAC.make(.sha256, stringToSign.bytes, key: signingKey).hexString
        return signature
    }
    
    private func timestamp(date: Date, shortDate: Bool) -> String {
        if !shortDate {
            dateFormatter.dateFormat = "yyyyMMdd'T'HHmmss'Z'"
        } else {
            dateFormatter.dateFormat = "yyyyMMdd"
        }
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        return dateFormatter.string(from: date)
    }
    
    fileprivate func credentialScope(timeStampShort: String) -> String {
        return  [timeStampShort, region.rawValue, "s3", "aws4_request"].joined(separator: "/")
    }
    
    private enum S3SignerError: Error {
        case badURL
        case putRequestRequiresPayloadData
        case unableToEncodeSignature
        case unableToEncodeStringToSign
        case unableToEncodeURLPath
        case unableToEncodeCredentialScope
    }
}



//Testing Extension for Private functions//////
//
//extension S3SignerAWS {
//    
//    public func TcanonicalHeaders(headers: [String: String]) -> String {
//        return canonicalHeaders(headers: headers)
//    }
//    
//    public func TsignedHeaders(headers: [String: String]) -> String {
//        return signedHeaders(headers: headers)
//    }
//    
//    public func TcreateCanonicalRequest(httpMethod: HTTPMethod, url: URL, pathEncoding: CharacterSet, queryEncoding: CharacterSet, headers: [String:String], bodyDigest: String) -> String {
//        return try! createCanonicalRequest(httpMethod: httpMethod, url: url, pathEncoding: pathEncoding, queryEncoding: queryEncoding, headers: headers, bodyDigest: bodyDigest)
//    }
//    
//    public func TcreateStringToSign(canonicalRequest: String, timeStampLong: String, timeStampShort: String) -> String {
//        return try! createStringToSign(canonicalRequest: canonicalRequest, timeStampLong: timeStampLong, timeStampShort: timeStampShort)
//    }
//    
//    public func TgetSignature(stringToSign: String, timeStampShort: String) -> String {
//        return try! getSignature(stringToSign: stringToSign, timeStampShort: timeStampShort)
//    }
//    
//    public func TupdateHeaders(headers: [String:String], url: URL, longDate: String, bodyDigest: String) -> [String:String] {
//        return updateHeaders(headers: headers, url: url, longDate: longDate, bodyDigest: bodyDigest)
//    }
//    
//    public func TcredentialScope(timeStampShort: String, regionName: String) -> String {
//        return  [timeStampShort, regionName, "s3", "aws4_request"].joined(separator: "/")
//    }
//}

