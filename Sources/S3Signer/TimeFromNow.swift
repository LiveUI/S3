public typealias Seconds = Int

/// How long until the V4 Pre-signed URL expires.
///
/// - thirtyMinutes: 30 minutes
/// - oneHour: 60 minutes
/// - threeHours: 180 minutes
/// - custom: Custom expiration time, in seconds.
public enum TimeFromNow {
    case thirtyMinutes
    case oneHour
    case threeHours
    case custom(Seconds)
	
	
    /// V4 expiration.
    internal var expiration: Seconds {
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
