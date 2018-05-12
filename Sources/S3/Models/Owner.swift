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
    
    /// Owner's ID
    public let id: String
    
    /**
    Owner's name
    - *This value is only included in the response in the US East (N. Virginia), US West (N. California), US West (Oregon), Asia Pacific (Singapore), Asia Pacific (Sydney), Asia Pacific (Tokyo), EU (Ireland), and South America (São Paulo) regions.*
    - *For a list of all the Amazon S3 supported regions and endpoints, see Regions and Endpoints in the AWS General Reference.*
    */
    public let name: String?
    
    enum CodingKeys: String, CodingKey {
        case id = "ID"
        case name = "DisplayName"
    }
    
}
