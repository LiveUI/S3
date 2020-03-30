import Foundation
import NIO
import HTTPMediaTypes


/// S3 client Protocol
public protocol S3Client {    
    /// Get list of objects
    func buckets() -> EventLoopFuture<BucketsInfo>
    
    /// Create a bucket
    func create(bucket: String, region: Region?) -> EventLoopFuture<Void>
    
    /// Delete a bucket wherever it is
//    func delete(bucket: String, on container: Container) -> EventLoopFuture<Void>
    
    /// Delete a bucket
    func delete(bucket: String, region: Region?) -> EventLoopFuture<Void>
    
    /// Get bucket location
    func location(bucket: String) -> EventLoopFuture<Region>
    
    /// Get list of objects
    func list(bucket: String, region: Region?) -> EventLoopFuture<BucketResults>
    
    /// Get list of objects
    func list(bucket: String, region: Region?, headers: [String: String]) -> EventLoopFuture<BucketResults>
    
    /// Upload file to S3
    func put(file: File.Upload) -> EventLoopFuture<File.Response>
    
    /// Upload file to S3
    func put(file: File.Upload, headers: [String: String]) -> EventLoopFuture<File.Response>
    
    /// Upload file to S3
    func put(file url: URL, destination: String, access: AccessControlList) -> EventLoopFuture<File.Response>
    
    /// Upload file to S3
    func put(file url: URL, destination: String, bucket: String?, access: AccessControlList) -> EventLoopFuture<File.Response>
    
    /// Upload file to S3
    func put(file path: String, destination: String, access: AccessControlList) -> EventLoopFuture<File.Response>
    
    /// Upload file to S3
    func put(file path: String, destination: String, bucket: String?, access: AccessControlList) -> EventLoopFuture<File.Response>
    
    /// Upload file to S3
    func put(string: String, destination: String) -> EventLoopFuture<File.Response>
    
    /// Upload file to S3
    func put(string: String, destination: String, access: AccessControlList) -> EventLoopFuture<File.Response>
    
    /// Upload file to S3
    func put(string: String, mime: HTTPMediaType, destination: String) -> EventLoopFuture<File.Response>
    
    /// Upload file to S3
    func put(string: String, mime: HTTPMediaType, destination: String, access: AccessControlList) -> EventLoopFuture<File.Response>
    
    /// Upload file to S3
    func put(string: String, mime: HTTPMediaType, destination: String, bucket: String?, access: AccessControlList) -> EventLoopFuture<File.Response>
    
    /// File URL
    func url(fileInfo file: LocationConvertible) throws -> URL
    
    /// Retrieve file data from S3
    func get(fileInfo file: LocationConvertible) -> EventLoopFuture<File.Info>
    
    /// Retrieve file data from S3
    func get(fileInfo file: LocationConvertible, headers: [String: String]) -> EventLoopFuture<File.Info>
    
    /// Retrieve file data from S3
    func get(file: LocationConvertible) -> EventLoopFuture<File.Response>
    
    /// Retrieve file data from S3
    func get(file: LocationConvertible, headers: [String: String]) -> EventLoopFuture<File.Response>
    
    /// Delete file from S3
    func delete(file: LocationConvertible) -> EventLoopFuture<Void>
    
    /// Delete file from S3
    func delete(file: LocationConvertible, headers: [String: String]) -> EventLoopFuture<Void>
    
    /// Copy file on S3
    func copy(file: LocationConvertible, to: LocationConvertible, headers: [String: String]) -> EventLoopFuture<File.CopyResponse>
}

extension S3Client {
    
    /// Retrieve file data from S3
    func get(file: LocationConvertible) -> EventLoopFuture<File.Response> {
        return get(file: file, headers: [:])
    }
    
    /// Copy file on S3
    public func copy(file: LocationConvertible, to: LocationConvertible) -> EventLoopFuture<File.CopyResponse> {
        return self.copy(file: file, to: to, headers: [:])
    }
    
    static var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSXXXXX"
        return formatter
    }
    
    static var headerDateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "EEE',' dd MMM yyyy HH':'mm':'ss 'GMT'"
        return formatter
    }
    
}
