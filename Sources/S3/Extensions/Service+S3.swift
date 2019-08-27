import S3Signer
import Vapor

extension Services {

    /// Convenience method to register both S3Signer and S3Client
    public mutating func register(s3 config: S3Signer.Config, defaultBucket: String) throws {
        try S3(defaultBucket: defaultBucket, config: config, services: &self)
    }

}
