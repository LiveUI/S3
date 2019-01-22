/// AWS Region
public struct Region {
    
    /// name of the region, see Name
    public let name: Name
    
    /// name of the custom host, can contain IP and/or port (e.g. 127.0.0.1:9000)
    public let hostName: String?
    
    /// use TLS/https (defaults to true)
    public let useTLS: Bool
    
    public struct Name: ExpressibleByStringLiteral, LosslessStringConvertible {
        
        /// US East (N. Virginia)
        public static let usEast1: Name = "us-east-1"
        
        /// US East (Ohio)
        public static let usEast2: Name = "us-east-2"
        
        /// US West (N. California)
        public static let usWest1: Name = "us-west-1"
        
        /// US West (Oregon)
        public static let usWest2: Name = "us-west-2"
        
        /// Canada (Central)
        public static let caCentral1: Name = "ca-central-1"
        
        /// EU (Frankfurt)
        public static let euCentral1: Name = "eu-central-1"
        
        /// EU (Ireland)
        public static let euWest1: Name = "eu-west-1"
        
        /// EU (London)
        public static let euWest2: Name = "eu-west-2"
        
        /// EU (Paris)
        public static let euWest3: Name = "eu-west-3"
        
        /// Asia Pacific (Tokyo)
        public static let apNortheast1: Name = "ap-northeast-1"
        
        /// Asia Pacific (Seoul)
        public static let apNortheast2: Name = "ap-northeast-2"
        
        /// Asia Pacific (Osaka-Local)
        public static let apNortheast3: Name = "ap-northeast-3"
        
        /// Asia Pacific (Singapore)
        public static let apSoutheast1: Name = "ap-southeast-1"
        
        /// Asia Pacific (Sydney)
        public static let apSoutheast2: Name = "ap-southeast-2"
        
        /// Asia Pacific (Mumbai)
        public static let apSouth1: Name = "ap-south-1"
        
        /// South America (São Paulo)
        public static let saEast1: Name = "sa-east-1"
        
        public let description: String
        
        public init(_ value: String) {
            self.description = value
        }
        
        public init(stringLiteral value: String) {
            self.init(value)
        }
    }
    
    /// initializer for a (custom) region. If you use a custom hostName, you
    /// still need a region (e.g. use usEast1 for Minio)
    public init(name: Name, hostName: String? = nil, useTLS: Bool = true) {
        self.name = name
        self.hostName = hostName
        self.useTLS = useTLS
    }
    
    @available(*, deprecated, renamed: "init(name:)", message: "This initializer has been deprecated, please use init(name:hostName:useTLS:) instead")
    public init?(rawValue value: String) {
        self.name = Name(value)
        self.hostName = nil
        self.useTLS = true
    }
    
}


extension Region {
    
    /// Base URL / Host
    public var host: String {
        return hostName ?? "s3.\(name).amazonaws.com"
    }
}

extension Region {
    
    /// convenience var for US East (N. Virginia)
    public static let usEast1 = Region(name: .usEast1)
    
    /// convenience var for US East (Ohio)
    public static let usEast2 = Region(name: .usEast2)
    
    /// convenience var for US West (N. California)
    public static let usWest1 = Region(name: .usWest1)
    
    /// convenience var for US West (Oregon)
    public static let usWest2 = Region(name: .usWest2)
    
    /// convenience var for Canada (Central)
    public static let caCentral1 = Region(name: .caCentral1)
    
    /// convenience var for EU (Frankfurt)
    public static let euCentral1 = Region(name: .euCentral1)
    
    /// convenience var for EU (Ireland)
    public static let euWest1 = Region(name: .euWest1)
    
    /// convenience var for EU (London)
    public static let euWest2 = Region(name: .euWest2)
    
    /// convenience var for EU (Paris)
    public static let euWest3 = Region(name: .euWest3)
    
    /// convenience var for Asia Pacific (Tokyo)
    public static let apNortheast1 = Region(name: .apNortheast1)
    
    /// convenience var for Asia Pacific (Seoul)
    public static let apNortheast2 = Region(name: .apNortheast2)
    
    /// convenience var for Asia Pacific (Osaka-Local)
    public static let apNortheast3 = Region(name: .apNortheast3)
    
    /// convenience var for Asia Pacific (Singapore)
    public static let apSoutheast1 = Region(name: .apSoutheast1)
    
    /// convenience var for Asia Pacific (Sydney)
    public static let apSoutheast2 = Region(name: .apSoutheast2)
    
    /// convenience var for Asia Pacific (Mumbai)
    public static let apSouth1 = Region(name: .apSouth1)
    
    /// convenience var for South America (São Paulo)
    public static let saEast1 = Region(name: .saEast1)
}

/// Codable support for Region
extension Region: Codable {
    
    /// decodes a string (see Name) to a Region (does not support custom hosts)
    public init(from decoder: Decoder) throws {
        try self.init(name: .init(.init(from: decoder)))
    }
    
    /// encodes the name (see Name, does not support custom hosts)
    public func encode(to encoder: Encoder) throws {
        try name.description.encode(to: encoder)
    }
}
