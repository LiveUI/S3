import Foundation
import XMLCoding
import AsyncHTTPClient


extension HTTPClient.Response {
    
    func decode<T>(to: T.Type) throws -> T where T: Decodable {
        guard var b = body, let data = b.readBytes(length: b.readableBytes) else {
            throw S3.Error.badResponse(self)
        }

        let decoder = XMLDecoder()
        decoder.dateDecodingStrategy = .formatted(S3.dateFormatter)
        return try decoder.decode(T.self, from: Data(data))
    }
    
}
