import Foundation


extension Error {
    
    /// Return S3 Error if possible
    public func s3Error() -> S3.Error? {
        guard let error = self as? S3.Error else {
            return nil
        }
        return error
    }
    
    /// Return S3 ErrorMessage if possible
    public func s3ErrorMessage() -> ErrorMessage? {
        guard let error = self as? S3.Error else {
            return nil
        }
        switch error {
        case .errorResponse(_, let errorMessage):
            return errorMessage
        default:
            return nil
        }
    }
    
    /// Return S3 error status code if possible
    public func s3ErrorCode() -> HTTPResponseStatus? {
        guard let error = self as? S3.Error else {
            return nil
        }
        switch error {
        case .errorResponse(let errorCode, _):
            return errorCode
        default:
            return nil
        }
    }
    
}
