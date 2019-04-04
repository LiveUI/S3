import Foundation
import HTTP

/// Private interface
extension S3Signer {
    
    private struct PresignedURLAuthQuery {
        
        var algorithm: String
        var credentials: String
        var date: String
        var expires: String
        var signedHeaders: String
        
        enum Keys: String {
            case algorithm = "X-Amz-Algorithm"
            case credentials = "X-Amz-Credential"
            case date = "X-Amz-Date"
            case expires = "X-Amz-Expires"
            case signedHeaders = "X-Amz-SignedHeaders"
        }
        
        func queryItems() -> [URLQueryItem] {
            return [
                URLQueryItem(name: Keys.algorithm.rawValue, value: algorithm),
                URLQueryItem(name: Keys.credentials.rawValue, value: credentials),
                URLQueryItem(name: Keys.date.rawValue, value: date),
                URLQueryItem(name: Keys.expires.rawValue, value: expires),
                URLQueryItem(name: Keys.signedHeaders.rawValue, value: signedHeaders)
            ]
        }
        
    }
    
    func presignedURL(for httpMethod: HTTPMethod, url: URL, expiration: Expiration, region: Region? = nil, headers: [String: String] = [:], dates: Dates) throws -> URL? {
        var updatedHeaders = headers
        
        let region = region ?? config.region
        
        updatedHeaders["host"] = url.host ?? region.host
        
        var (canonRequest, urlComponents) = try presignedURLCanonRequest(httpMethod, dates: dates, expiration: expiration, url: url, region: region, headers: updatedHeaders)
        
        let stringToSign = try createStringToSign(canonRequest, dates: dates, region: region)
        let signature = try createSignature(stringToSign, timeStampShort: dates.short, region: region)
        urlComponents.queryItems?.insert(URLQueryItem(name: "X-Amz-Signature", value: signature), at: 0)
        return urlComponents.url
    }
    
    private func presignedURLCanonRequest(_ httpMethod: HTTPMethod, dates: Dates, expiration: Expiration, url: URL, region: Region, headers: [String: String]) throws -> (String, URLComponents) {
        guard let credScope = credentialScope(dates.short, region: region).encode(type: .queryAllowed),
            let signHeaders = signed(headers: headers).encode(type: .queryAllowed) else {
                throw Error.invalidEncoding
        }
        
        guard var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            throw Error.badURL(url.absoluteString)
        }
        
        var urlQueryItems = urlComponents.queryItems ?? []
        
        let authQuery = PresignedURLAuthQuery(algorithm: "AWS4-HMAC-SHA256",
                                            credentials: config.accessKey,
                                            date: credScope,
                                            expires: "\(expiration.value)",
                                            signedHeaders: signHeaders)
        
        urlQueryItems.insert(contentsOf: authQuery.queryItems(), at: 0)
        urlComponents.queryItems = urlQueryItems
        
        return (
            [
                httpMethod.string,
                formattedPath(urlComponents.path),
                formattedQueryItems(urlQueryItems),
                canonicalHeaders(headers),
                signed(headers: headers),
                "UNSIGNED-PAYLOAD"
                ].joined(separator: "\n"),
            urlComponents
        )
    }
    
}
