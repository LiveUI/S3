import Foundation
import HTTPMediaTypes


extension S3 {
    
    /// Upload file content to S3, full set
    public func put(string: String, mime: HTTPMediaType, destination: String, bucket: String?, access: AccessControlList) -> EventLoopFuture<File.Response> {
        guard let data: Data = string.data(using: String.Encoding.utf8) else {
            return eventLoop.makeFailedFuture(Error.badStringData)
        }
        let file = File.Upload(data: data, bucket: bucket, destination: destination, access: access, mime: mime.description)
        return put(file: file)
    }
    
    /// Upload file content to S3
    public func put(string: String, mime: HTTPMediaType, destination: String, access: AccessControlList) -> EventLoopFuture<File.Response> {
        return put(string: string, mime: mime, destination: destination, bucket: nil, access: access)
    }
    
    /// Upload file content to S3
    public func put(string: String, destination: String, access: AccessControlList) -> EventLoopFuture<File.Response> {
        return put(string: string, mime: .plainText, destination: destination, bucket: nil, access: access)
    }
    
    /// Upload file content to S3
    public func put(string: String, mime: HTTPMediaType, destination: String) -> EventLoopFuture<File.Response> {
        return put(string: string, mime: mime, destination: destination, access: .privateAccess)
    }
    
    /// Upload file content to S3
    public func put(string: String, destination: String) -> EventLoopFuture<File.Response> {
        return put(string: string, mime: .plainText, destination: destination, bucket: nil, access: .privateAccess)
    }
    
}
