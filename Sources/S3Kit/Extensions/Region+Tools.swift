import S3Signer
import Foundation


extension Region {
    
    /// Get S3 URL string for bucket
    public func urlString(bucket: String) -> String {
        return host.trimmingCharacters(in: CharacterSet(charactersIn: "/")) + bucket
    }
    
    /// Get S3 URL for bucket
    public func url(bucket: String) -> URL? {
        return URL(string: urlString(bucket: bucket))
    }
    
}
