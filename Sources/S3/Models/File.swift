//
//  File.swift
//  S3
//
//  Created by Ondrej Rafaj on 12/05/2018.
//

import Foundation
@_exported import Vapor


/// File data
public struct File {
    
    /// File to be uploaded (PUT)
    public struct Upload: LocationConvertible {
        
        /// Data
        public internal(set) var data: Data
        
        /// Override target bucket
        public internal(set) var bucket: String?
        
        /// S3 file path
        public internal(set) var path: String
        
        /// S3 Region
        public internal(set) var region: Region?
        
        /// Desired access control for file
        public internal(set) var access: AccessControlList = .privateAccess
        
        /// Desired file type (mime) for the uploaded file
        public internal(set) var mime: String = "text/plain"
        
        // MARK: Initialization
        
        /// File data to be uploaded
        public init(data: Data, bucket: String? = nil, destination: String, access: AccessControlList = .privateAccess, mime: String = MediaType.plainText.description) {
            self.data = data
            self.bucket = bucket
            self.path = destination
            self.access = access
            self.mime = mime
        }
        
        /// File to be uploaded
        public init(file: URL, bucket: String? = nil, destination: String, access: AccessControlList = .privateAccess) throws {
            self.data = try Data(contentsOf: file)
            self.bucket = bucket
            self.path = destination
            self.access = access
            self.mime = S3.mimeType(forFileAtUrl: file)
        }
        
        /// File to be uploaded
        public init(file: String, bucket: String? = nil, destination: String, access: AccessControlList = .privateAccess) throws {
            guard let url = URL(string: file) else {
                throw S3.Error.invalidUrl
            }
            try self.init(file: url, bucket: bucket, destination: destination, access: access)
        }
        
    }
    
    /// File to be located
    public struct Location: LocationConvertible {
        
        /// Override target bucket
        public internal(set) var bucket: String?
        
        /// S3 file path
        public internal(set) var path: String
        
        /// Region
        public internal(set) var region: Region?
        
        /// Initializer
        public init(path: String, bucket: String? = nil, region: Region? = nil) {
            self.path = path
            self.bucket = bucket
            self.region = region
        }
        
    }
    
    /// File response comming back from S3
    public struct Response: Content {
        
        /// Data
        public internal(set) var data: Data
        
        /// Override target bucket
        public internal(set) var bucket: String?
        
        /// S3 file path
        public internal(set) var path: String
        
        /// Access control for file
        public internal(set) var access: AccessControlList?
        
        /// File type (mime)
        public internal(set) var mime: String
        
    }
    
}
