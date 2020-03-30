import Vapor
import S3Signer

extension Application {
    public struct S3 {
        fileprivate let application: Application
        
        struct ConfigurationKey: StorageKey {
            typealias Value = S3Signer.Config
        }
        
        public var configuration: S3Signer.Config? {
            get {
                application.storage[ConfigurationKey.self]
            }
            nonmutating set {
                application.storage[ConfigurationKey.self] = newValue
            }
        }
    }
    
    public var s3: S3 { .init(application: self) }
}
