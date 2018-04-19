//
//  FileInfo.swift
//  S3
//
//  Created by Ondrej Rafaj on 19/04/2018.
//

import Foundation


public protocol FileInfo {
    /// Override target bucket
    var bucket: String? { get }
    
    /// S3 file path
    var path: String { get }
}
