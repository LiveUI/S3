import Foundation
import S3Signer


// Helper S3 extension for working with buckets
extension S3 {
    
    // MARK: Buckets
    
    /// Get acl file information (ACL)
    /// https://docs.aws.amazon.com/AmazonS3/latest/API/RESTObjectGETacl.html
    public func get(acl file: LocationConvertible, headers: [String: String], on eventLoop: EventLoop) -> EventLoopFuture<File.Info> {
        fatalError("Not implemented")
    }
    
    /// Get acl file information
    /// https://docs.aws.amazon.com/AmazonS3/latest/API/RESTObjectGETacl.html
    func get(acl file: LocationConvertible, on eventLoop: EventLoop) -> EventLoopFuture<File.Info> {
        return get(fileInfo: file, headers: [:], on: eventLoop)
    }
    
    /// Get file information (HEAD)
    /// https://docs.aws.amazon.com/AmazonS3/latest/API/RESTObjectHEAD.html
    public func get(fileInfo file: LocationConvertible, headers strHeaders: [String: String], on eventLoop: EventLoop) -> EventLoopFuture<File.Info> {
        let url: URL
        let headers: HTTPHeaders

        do {
            url = try makeURLBuilder().url(file: file)
            headers = try signer.headers(for: .HEAD, urlString: url.absoluteString, headers: strHeaders, payload: .none)
        } catch let error {
            return eventLoop.makeFailedFuture(error)
        }

        return make(request: url, method: .HEAD, headers: headers, data: Data(), on: eventLoop).flatMapThrowing { response in
            try self.check(response)
            
            let bucket = file.bucket ?? self.defaultBucket
            let region = file.region ?? self.signer.config.region
            let mime = response.headers.string(File.Info.CodingKeys.mime.rawValue)
            let size = response.headers.int(File.Info.CodingKeys.size.rawValue)
            let server = response.headers.string(File.Info.CodingKeys.server.rawValue)
            let etag = response.headers.string(File.Info.CodingKeys.etag.rawValue)
            let expiration = response.headers.date(File.Info.CodingKeys.expiration.rawValue)
            let created = response.headers.date(File.Info.CodingKeys.created.rawValue)
            let modified = response.headers.date(File.Info.CodingKeys.modified.rawValue)
            let versionId = response.headers.string(File.Info.CodingKeys.versionId.rawValue)
            let storageClass = response.headers.string(File.Info.CodingKeys.storageClass.rawValue)
            
            let info = File.Info(bucket: bucket, region: region, path: file.path, access: .authenticatedRead, mime: mime, size: size, server: server, etag: etag, expiration: expiration, created: created, modified: modified, versionId: versionId, storageClass: storageClass)
            return info
        }
    }
    
    /// Get file information (HEAD)
    /// https://docs.aws.amazon.com/AmazonS3/latest/API/RESTObjectHEAD.html
    public func get(fileInfo file: LocationConvertible, on eventLoop: EventLoop) -> EventLoopFuture<File.Info> {
        return get(fileInfo: file, headers: [:], on: eventLoop)
    }
    
}
