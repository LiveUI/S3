import Foundation
import NIO
import S3Signer


// Helper S3 extension for working with buckets
extension S3 {
    
    // MARK: Buckets
    
    /// Get bucket location
    public func location(bucket: String) -> EventLoopFuture<Region> {
        let url: URL
        let awsHeaders: HTTPHeaders
        let region = Region.euWest2

        do {
            url = try makeURLBuilder().url(region: region, bucket: bucket, path: nil)
            awsHeaders = try signer.headers(for: .GET, urlString: url.absoluteString, region: region, bucket: bucket, payload: .none)
        } catch let error {
            return eventLoop.makeFailedFuture(error)
        }

        return make(request: url, method: .GET, headers: awsHeaders, data: Data()).flatMapThrowing { response in
            if response.status == .notFound {
                throw Error.notFound
            }
            if response.status == .ok {
                return region
            } else {
                if let error = try? response.decode(to: ErrorMessage.self), error.code == "PermanentRedirect", let endpoint = error.endpoint {
                    if endpoint == "s3.amazonaws.com" {
                        return Region.usEast1
                    } else {
                        // Split bucket.s3.region.amazonaws.com into parts
                        // Drop .com and .amazonaws
                        // Get region (last part)
                        guard let regionString = endpoint.split(separator: ".").dropLast(2).last?.lowercased() else {
                            throw Error.badResponse(response)
                        }
                        return Region(name: .init(regionString))
                    }
                } else {
                    throw Error.badResponse(response)
                }
            }
        }
    }
    
    /// Delete bucket
    public func delete(bucket: String, region: Region? = nil) -> EventLoopFuture<Void> {
        let url: URL
        let awsHeaders: HTTPHeaders

        do {
            url = try makeURLBuilder().url(region: region, bucket: bucket, path: nil)
            awsHeaders = try signer.headers(for: .DELETE, urlString: url.absoluteString, region: region, bucket: bucket, payload: .none)
        } catch let error {
            return eventLoop.makeFailedFuture(error)
        }

        return make(request: url, method: .DELETE, headers: awsHeaders, data: Data()).flatMapThrowing(self.check).map { _ in
            return Void()
        }
    }
    
    /// Create a bucket
    public func create(bucket: String, region: Region? = nil) -> EventLoopFuture<Void> {
        let region = region ?? signer.config.region
        let content = """
        <CreateBucketConfiguration xmlns="http://s3.amazonaws.com/doc/2006-03-01/">
            <LocationConstraint>\(region.name)</LocationConstraint>
        </CreateBucketConfiguration>
        """
        let data = Data(content.utf8)

        let awsHeaders: HTTPHeaders
        let url: URL

        do {
            url = try makeURLBuilder().url(region: region, bucket: bucket, path: nil)
            awsHeaders = try signer.headers(for: .PUT, urlString: url.absoluteString, region: region, bucket: bucket, payload: .bytes(data))
        } catch let error {
            return eventLoop.makeFailedFuture(error)
        }

        return make(request: url, method: .PUT, headers: awsHeaders, data: data).flatMapThrowing(self.check).map { _ in
            return Void()
        }
    }
    
}
