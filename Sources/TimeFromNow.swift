//
//  TimeFromNow.swift
//  S3SignerAWS
//
//  Created by Justin on 10/10/16.
//
//

import Foundation

public typealias Seconds = Int

public enum TimeFromNow {
    case thirtyMinutes
    case oneHour
    case threeHours
    case custom(Seconds)
    
    var v4Expiration: Seconds {
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
    
    var v2Expiration: UInt64 {
        switch self {
        case .thirtyMinutes:
            return v2Expirationcalc(seconds: 60 * 30)
        case .oneHour:
            return v2Expirationcalc(seconds: 60 * 60)
        case .threeHours:
            return v2Expirationcalc(seconds: 60 * 60 * 3)
        case .custom(let exp):
            return v2Expirationcalc(seconds: exp)
        }
    }
    
    private func v2Expirationcalc(seconds: Seconds) -> UInt64 {
        return UInt64(floor(Date().timeIntervalSince1970 + Double(seconds)))
    }
}
