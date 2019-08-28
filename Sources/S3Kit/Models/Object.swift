import Foundation


/// S3 object
public struct Object: Codable {
    
    /// The object's key / file name
    public let fileName: String
    
    /// STANDARD | STANDARD_IA | ONEZONE_IA | REDUCED_REDUNDANCY | GLACIER
    public let storageClass: String?
    
    /// The entity tag is an MD5 hash of the object. ETag reflects only changes to the contents of an object, not its metadata
    public let etag: String
    
    /// Owner
    public let owner: Owner?
    
    /// Size in bytes of the object
    public let size: Int?
    
    /// Date and time the object was last modified
    public let lastModified: Date
    
    enum CodingKeys: String, CodingKey {
        case fileName = "Key"
        case storageClass = "StorageClass"
        case etag = "ETag"
        case owner = "Owner"
        case size = "Size"
        case lastModified = "LastModified"
    }
    
}
