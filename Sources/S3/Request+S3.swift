import Vapor
import S3Kit

extension Request {
    public var s3: S3 {
        guard let config = application.s3.configuration else {
            fatalError("S3 is not configured, please use application.s3.configuration = ...")
        }
        
        return .init(config: config, eventLoop: eventLoop, httpClient: application.client.http)
    }
}
