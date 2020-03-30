import Foundation
import NIO
import NIOHTTP1


// Helper S3 extension for getting file indexes
extension S3 {
    
    /// Get list of objects
    public func list(bucket: String, region: Region? = nil, headers: [String: String]) -> EventLoopFuture<BucketResults> {
        let region = region ?? signer.config.region
        guard let baseUrl = URL(string: region.hostUrlString(bucket: bucket)), let host = baseUrl.host,
            var components = URLComponents(string: baseUrl.absoluteString) else {
            return eventLoop.makeFailedFuture(S3.Error.invalidUrl)
        }
        components.queryItems = [
            URLQueryItem(name: "list-type", value: "2")
        ]
        guard let url = components.url else {
            return eventLoop.makeFailedFuture(S3.Error.invalidUrl)
        }

        let awsHeaders: HTTPHeaders

        do {
            var headers = headers
            headers["host"] = host
            awsHeaders = try signer.headers(for: .GET, urlString: url.absoluteString, region: region, bucket: bucket, headers: headers, payload: .none)
        } catch let error {
            return eventLoop.makeFailedFuture(error)
        }

        return make(request: url, method: .GET, headers: awsHeaders, data: Data()).flatMapThrowing { response in
            try self.check(response)
            return try response.decode(to: BucketResults.self)
        }
    }
    
    /// Get list of objects
    public func list(bucket: String, region: Region? = nil) -> EventLoopFuture<BucketResults> {
        return list(bucket: bucket, region: region, headers: [:])
    }
    
}
