import Foundation
import S3Signer


extension Region {
    
    /// Host URL including scheme
    public func hostUrlString(bucket: String? = nil) -> String {
//        return "http://localhost:4444/"
        if let bucket = bucket {
            return urlProtocol + host.finished(with: "/") + bucket
        }
        return urlProtocol + host.finished(with: "/")
    }
    
    private var urlProtocol: String {
        return useTLS ? "https://" : "http://"
    }

}


/// URL builder
public protocol URLBuilder {
    
    /// Initializer
    init(defaultBucket: String, config: S3Signer.Config)
    
    /// Plain Base URL with no bucket specified
    ///     *Format: https://s3.eu-west-2.amazonaws.com/
    func plain(region: Region?) throws -> URL
    
    /// Base URL for S3 region
    ///     *Format: https://bucket.s3.eu-west-2.amazonaws.com/path_or_parameter*
    func url(region: Region?, bucket: String?, path: String?) throws -> URL
    
    /// Base URL for a file in a bucket
    /// * Format: https://s3.eu-west-2.amazonaws.com/bucket/file.txt
    ///     * We can't have a bucket in the host or DELETE will attempt to delete the bucket, not file!
    func url(file: LocationConvertible) throws -> URL
    
}
