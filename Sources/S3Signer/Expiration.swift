import Foundation


/// Pre-sign URL expiration time
public enum Expiration {
    
    public typealias Seconds = Int
    
    /// 30 minutes
    case thirtyMinutes
    
    /// 60 minutes
    case hour
    
    /// 180 minutes
    case threeHours
    
    /// Custom expiration time, in seconds.
    case custom(Seconds)
}

extension Expiration {
    
    /// Expiration Value
    var value: Seconds {
        switch self {
        case .thirtyMinutes:
            return 60 * 30
        case .hour:
            return 60 * 60
        case .threeHours:
            return 60 * 60 * 3
        case .custom(let exp):
            return exp
        }
    }
    
}
