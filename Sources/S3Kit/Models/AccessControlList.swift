import Foundation


/// Available access control list values for "x-amz-acl" header as specified in AWS documentation
public enum AccessControlList: String, Codable {
    
    /// Owner gets FULL_CONTROL. No one else has access rights (default).
    case privateAccess = "private"
    
    /// Owner gets FULL_CONTROL. The AllUsers group (see Who Is a Grantee? at https://docs.aws.amazon.com/AmazonS3/latest/dev/acl-overview.html#specifying-grantee) gets READ access.
    case publicRead = "public-read"
    
    /// Owner gets FULL_CONTROL. The AllUsers group gets READ and WRITE access. Granting this on a bucket is generally not recommended.
    case publicReadWrite = "public-read-write"
    
    /// Owner gets FULL_CONTROL. Amazon EC2 gets READ access to GET an Amazon Machine Image (AMI) bundle from Amazon S3.
    case awsExecRead = "aws-exec-read"
    
    /// Owner gets FULL_CONTROL. The AuthenticatedUsers group gets READ access.
    case authenticatedRead = "authenticated-read"
    
    /// Object owner gets FULL_CONTROL. Bucket owner gets READ access. If you specify this canned ACL when creating a bucket, Amazon S3 ignores it.
    case bucketOwnerRead = "bucket-owner-read"
    
    /// Both the object owner and the bucket owner get FULL_CONTROL over the object. If you specify this canned ACL when creating a bucket, Amazon S3 ignores it.
    case bucketOwnerFullControl = "bucket-owner-full-control"
    
    /// The LogDelivery group gets WRITE and READ_ACP permissions on the bucket. For more information about logs, see (https://docs.aws.amazon.com/AmazonS3/latest/dev/ServerLogs.html).
    case logDeliveryWrite = "log-delivery-write"
    
}
