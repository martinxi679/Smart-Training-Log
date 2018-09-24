//
//  Sports.swift
//  Smart Training Log
//

import Foundation

public enum Sport: String, CaseIterable {

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
}
