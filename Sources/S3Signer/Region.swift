import Foundation


/// AWS Region
public struct Region {
    
    /// name of the region, see RegionName
    public let name: RegionName

    /// name of the custom host, can contain IP and/or port (e.g. 127.0.0.1:9000)
    public let hostName: String?

    /// use TLS/https (defaults to true)
    public let useTLS: Bool
    
    public enum RegionName : String, Codable {
        /// US East (N. Virginia)
        case usEast1 = "us-east-1"
        
        /// US East (Ohio)
        case usEast2 = "us-east-2"
        
        /// US West (N. California)
        case usWest1 = "us-west-1"
        
        /// US West (Oregon)
        case usWest2 = "us-west-2"
        
        /// Canada (Central)
        case caCentral1 = "ca-central-1"
        
        /// EU (Frankfurt)
        case euCentral1 = "eu-central-1"
        
        /// EU (Ireland)
        case euWest1 = "eu-west-1"
        
        /// EU (London)
        case euWest2 = "eu-west-2"
        
        /// EU (Paris)
        case euWest3 = "eu-west-3"
        
        /// Asia Pacific (Tokyo)
        case apNortheast1 = "ap-northeast-1"
        
        /// Asia Pacific (Seoul)
        case apNortheast2 = "ap-northeast-2"
        
        /// Asia Pacific (Osaka-Local)
        case apNortheast3 = "ap-northeast-3"
        
        /// Asia Pacific (Singapore)
        case apSoutheast1 = "ap-southeast-1"
        
        /// Asia Pacific (Sydney)
        case apSoutheast2 = "ap-southeast-2"
        
        /// Asia Pacific (Mumbai)
        case apSouth1 = "ap-south-1"
        
        /// South America (São Paulo)
        case saEast1 = "sa-east-1"
    }

    /// initializer for a (custom) region. If you use a custom hostName, you
    /// still need a region (e.g. use usEast1 for Minio)
    public init(name: RegionName, hostName: String? = nil, useTLS: Bool = true) {
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
        return "s3.\(name.rawValue).amazonaws.com"
    }
}

extension Region {
    public init?(rawValue: String) {
        guard let name = RegionName(rawValue: rawValue) else {
            return nil
        }
        
        self.init(name: name)
    }
    
    /// convenience var for US East (N. Virginia)
    public static var usEast1: Region {
        return Region(name: RegionName.usEast1)
    }

    /// convenience var for US East (Ohio)
    public static var usEast2: Region {
        return Region(name: RegionName.usEast2)
    }

    /// convenience var for US West (N. California)
    public static var usWest1: Region {
        return Region(name: RegionName.usWest1)
    }

    /// convenience var for US West (Oregon)
    public static var usWest2: Region {
        return Region(name: RegionName.usWest2)
    }

    /// convenience var for Canada (Central)
    public static var caCentral1: Region {
        return Region(name: RegionName.caCentral1)
    }

    /// convenience var for EU (Frankfurt)
    public static var euCentral1: Region {
        return Region(name: RegionName.euCentral1)
    }

    /// convenience var for EU (Ireland)
    public static var euWest1: Region {
        return Region(name: RegionName.euWest1)
    }

    /// convenience var for EU (London)
    public static var euWest2: Region {
        return Region(name: RegionName.euWest2)
    }

    /// convenience var for EU (Paris)
    public static var euWest3: Region {
        return Region(name: RegionName.euWest3)
    }

    /// convenience var for Asia Pacific (Tokyo)
    public static var apNortheast1: Region {
        return Region(name: RegionName.apNortheast1)
    }

    /// convenience var for Asia Pacific (Seoul)
    public static var apNortheast2: Region {
        return Region(name: RegionName.apNortheast2)
    }

    /// convenience var for Asia Pacific (Osaka-Local)
    public static var apNortheast3: Region {
        return Region(name: RegionName.apNortheast3)
    }

    /// convenience var for Asia Pacific (Singapore)
    public static var apSoutheast1: Region {
        return Region(name: RegionName.apSoutheast1)
    }

    /// convenience var for Asia Pacific (Sydney)
    public static var apSoutheast2: Region {
        return Region(name: RegionName.apSoutheast2)
    }

    /// convenience var for Asia Pacific (Mumbai)
    public static var apSouth1: Region {
        return Region(name: RegionName.apSouth1)
    }

    /// convenience var for South America (São Paulo)
    public static var saEast1: Region {
        return Region(name: RegionName.saEast1)
    }
}

/// Codable support for Region
extension Region: Codable {

    /// decodes a string (see RegionName) to a Region (does not support custom hosts)
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        
        let name = try container.decode(String.self)
        
        guard let regionName = RegionName(rawValue: name) else {
            throw DecodingError.typeMismatch(String.self, DecodingError.Context(codingPath: [],
                                                                                debugDescription: "Could not find region for \(name)"))
        }
        
        self.name = regionName
        self.hostName = nil
        self.useTLS = true
    }
    
    /// encodes the name (see RegionName, does not support custom hosts)
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(self.name.rawValue)
    }
}
