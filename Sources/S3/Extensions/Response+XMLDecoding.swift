//
//  Response+XMLDecoding.swift
//  S3
//
//  Created by Ondrej Rafaj on 11/05/2018.
//

import Foundation
import Vapor
import XMLCoding


extension Response {
    
    func decode<T>(to: T.Type) throws -> T where T: Decodable {
        guard let data = http.body.data else {
            throw S3.Error.badResponse(self)
        }
        
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSXXXXX"
        
        let decoder = XMLDecoder()
        decoder.dateDecodingStrategy = .formatted(formatter)
        return try decoder.decode(T.self, from: data)
    }
    
}
