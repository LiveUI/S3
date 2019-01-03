import Foundation


/// AWS Region
public struct Region {
    
    /// name of the region, see Name
    public let name: String

    /// name of the custom host, can contain IP and/or port (e.g. 127.0.0.1:9000)
    public let hostName: String?

    /// use TLS/https (defaults to true)
    public let useTLS: Bool
    
    public enum Name {
        /// US East (N. Virginia)
        static let usEast1 = "us-east-1"
        
        /// US East (Ohio)
        static let usEast2 = "us-east-2"
        
        /// US West (N. California)
        static let usWest1 = "us-west-1"
        
        /// US West (Oregon)
        static let usWest2 = "us-west-2"
        
        /// Canada (Central)
        static let caCentral1 = "ca-central-1"
        
        /// EU (Frankfurt)
        static let euCentral1 = "eu-central-1"
        
        /// EU (Ireland)
        static let euWest1 = "eu-west-1"
        
        /// EU (London)
        static let euWest2 = "eu-west-2"
        
        /// EU (Paris)
        static let euWest3 = "eu-west-3"
        
        /// Asia Pacific (Tokyo)
        static let apNortheast1 = "ap-northeast-1"
        
        /// Asia Pacific (Seoul)
        static let apNortheast2 = "ap-northeast-2"
        
        /// Asia Pacific (Osaka-Local)
        static let apNortheast3 = "ap-northeast-3"
        
        /// Asia Pacific (Singapore)
        static let apSoutheast1 = "ap-southeast-1"
        
        /// Asia Pacific (Sydney)
        static let apSoutheast2 = "ap-southeast-2"
        
        /// Asia Pacific (Mumbai)
        static let apSouth1 = "ap-south-1"
        
        /// South America (São Paulo)
        static let saEast1 = "sa-east-1"
    }

    /// initializer for a (custom) region. If you use a custom hostName, you
    /// still need a region (e.g. use usEast1 for Minio)
    public init(name: String, hostName: String? = nil, useTLS: Bool = true) {
        self.name = name
        self.hostName = hostName
        self.useTLS = useTLS
    }
}


extension Region {
    
    /// Base URL / Host
    public var host: String {
        if let host = hostName {
            return host
        }
        return "s3.\(name).amazonaws.com"
    }
}

extension Region {

    /// convenience var for US East (N. Virginia)
    public static var usEast1: Region {
        return Region(name: Name.usEast1)
    }

    /// convenience var for US East (Ohio)
    public static var usEast2: Region {
        return Region(name: Name.usEast2)
    }

    /// convenience var for US West (N. California)
    public static var usWest1: Region {
        return Region(name: Name.usWest1)
    }

    /// convenience var for US West (Oregon)
    public static var usWest2: Region {
        return Region(name: Name.usWest2)
    }

    /// convenience var for Canada (Central)
    public static var caCentral1: Region {
        return Region(name: Name.caCentral1)
    }

    /// convenience var for EU (Frankfurt)
    public static var euCentral1: Region {
        return Region(name: Name.euCentral1)
    }

    /// convenience var for EU (Ireland)
    public static var euWest1: Region {
        return Region(name: Name.euWest1)
    }

    /// convenience var for EU (London)
    public static var euWest2: Region {
        return Region(name: Name.euWest2)
    }

    /// convenience var for EU (Paris)
    public static var euWest3: Region {
        return Region(name: Name.euWest3)
    }

    /// convenience var for Asia Pacific (Tokyo)
    public static var apNortheast1: Region {
        return Region(name: Name.apNortheast1)
    }

    /// convenience var for Asia Pacific (Seoul)
    public static var apNortheast2: Region {
        return Region(name: Name.apNortheast2)
    }

    /// convenience var for Asia Pacific (Osaka-Local)
    public static var apNortheast3: Region {
        return Region(name: Name.apNortheast3)
    }

    /// convenience var for Asia Pacific (Singapore)
    public static var apSoutheast1: Region {
        return Region(name: Name.apSoutheast1)
    }

    /// convenience var for Asia Pacific (Sydney)
    public static var apSoutheast2: Region {
        return Region(name: Name.apSoutheast2)
    }

    /// convenience var for Asia Pacific (Mumbai)
    public static var apSouth1: Region {
        return Region(name: Name.apSouth1)
    }

    /// convenience var for South America (São Paulo)
    public static var saEast1: Region {
        return Region(name: Name.saEast1)
    }
}

/// Codable support for Region
extension Region: Codable {

    /// decodes a string (see Name) to a Region (does not support custom hosts)
    public init(from decoder: Decoder) throws {
        self.name = try .init(from: decoder)
        self.hostName = nil
        self.useTLS = true
    }

    /// encodes the name (see Name, does not support custom hosts)
    public func encode(to encoder: Encoder) throws {
        try name.encode(to: encoder)
    }
}
