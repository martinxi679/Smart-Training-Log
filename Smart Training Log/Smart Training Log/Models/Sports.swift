//
//  Sports.swift
//  Smart Training Log
//

import Foundation

public enum Sports: String {

    case baseball = "BASEBALL"
    case mensBasketball = "BASKETBALL (M)"
    case womensBasketball = "BASKETBALL (W)"
    case mensCrossCountry = "CROSS COUNTRY (M)"
    case womensCrossCountry = "CROSS COUNTRY (W)"
    case football = "FOOTBALL"
    case golf = "GOLF"
    case softball = "SOFTBALL"
    case swimAndDive = "SWIMMING & DIVING"
    case mensTennis = "TENNIS (M)"
    case womensTennis = "TENNIS (W)"
    case mensTrack = "TRACK & FIELD (M)"
    case womensTrack = "TRACK & FIELD (W)"
    case vollyball = "VOLLEYBALL"

    static var count = 14

    static func sportForIndex(_ index: Int) -> Sports? {
        switch index {
        case 0: return .baseball
        case 1: return .mensBasketball
        case 2: return .womensBasketball
        case 3: return .mensCrossCountry
        case 4: return .womensCrossCountry
        case 5: return .football
        case 6: return .golf
        case 7: return .softball
        case 8: return .swimAndDive
        case 9: return .mensTennis
        case 10: return .womensTennis
        case 11: return .mensTrack
        case 12: return .womensTrack
        case 13: return .vollyball
        default: return nil
        }
    }
}
