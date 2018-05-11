//
//  Owner.swift
//  S3
//
//  Created by Ondrej Rafaj on 11/05/2018.
//

import Foundation
import Vapor


/// Owner object
public struct Owner: Content {
    
    public let id: String
    
    enum CodingKeys: String, CodingKey {
        case id = "ID"
    }
    
}
