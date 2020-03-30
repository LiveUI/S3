import Foundation
import NIO


extension S3 {
    
    // MARK: Move
    
    /// Copy file on S3
    public func move(file: LocationConvertible, to destination: LocationConvertible, headers: [String: String]) -> EventLoopFuture<File.CopyResponse> {
        return copy(file: file, to: destination, headers: headers).flatMap { copyResult in
            return self.delete(file: file).map { _ in
                return copyResult
            }
        }
    }
    
}
