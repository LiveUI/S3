import Foundation
import NIO


extension S3 {
    
    // MARK: Move
    
    /// Copy file on S3
    public func move(file: LocationConvertible, to destination: LocationConvertible, headers: [String: String], on eventLoop: EventLoop) -> EventLoopFuture<File.CopyResponse> {
        return copy(file: file, to: destination, headers: headers, on: eventLoop).flatMap { copyResult in
            return self.delete(file: file, on: eventLoop).map { _ in
                return copyResult
            }
        }
    }
    
}
