import Foundation


/// AWS Region
public struct Region {
    
    public let name: RegionName
    public let hostName: String?
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

public extension Region {
    init?(rawValue: String) {
        guard let name = RegionName(rawValue: rawValue) else {
            return nil
        }
        
        self.init(name: name)
    }
    
    static var usEast1: Region { return Region(name: RegionName.usEast1) }
    static var usEast2: Region { return Region(name: RegionName.usEast2) }
    static var usWest1: Region { return Region(name: RegionName.usWest1) }
    static var usWest2: Region { return Region(name: RegionName.usWest2) }
    static var caCentral1: Region { return Region(name: RegionName.caCentral1) }
    static var euCentral1: Region { return Region(name: RegionName.euCentral1) }
    static var euWest1: Region { return Region(name: RegionName.euWest1) }
    static var euWest2: Region { return Region(name: RegionName.euWest2) }
    static var euWest3: Region { return Region(name: RegionName.euWest3) }
    static var apNortheast1: Region { return Region(name: RegionName.apNortheast1) }
    static var apNortheast2: Region { return Region(name: RegionName.apNortheast2) }
    static var apNortheast3: Region { return Region(name: RegionName.apNortheast3) }
    static var apSoutheast1: Region { return Region(name: RegionName.apSoutheast1) }
    static var apSoutheast2: Region { return Region(name: RegionName.apSoutheast2) }
    static var apSouth1: Region { return Region(name: RegionName.apSouth1) }
    static var saEast1: Region { return Region(name: RegionName.saEast1) }
}

extension Region: Codable {
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
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(self.name.rawValue)
    }
}
