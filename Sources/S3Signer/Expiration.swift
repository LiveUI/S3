import Foundation

public typealias Seconds = Int

/// Pre-Sign URL Expiration time
public enum Expiration {
    /// 30 minutes
    case thirtyMinutes
    
    /// 60 minutes
    case oneHour
    
    /// 180 minutes
    case threeHours
    
    /// Custom expiration time, in seconds.
    case custom(Seconds)
}

extension Expiration {
    /// Expiration Value
    internal var value: Seconds {
        switch self {
        case .thirtyMinutes:
            return 60 * 30
        case .oneHour:
            return 60 * 60
        case .threeHours:
            return 60 * 60 * 3
        case .custom(let exp):
            return exp
        }
    }
}
