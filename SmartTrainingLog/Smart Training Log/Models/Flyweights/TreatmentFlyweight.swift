//
//  TreatmentFlyweight.swift
//  Smart Training Log
//
//  Created by Kasper Gammeltoft on 9/25/18.
//  Copyright © 2018 CS4261. All rights reserved.
//

import Foundation

struct TreatmentFlywieght: TreatmentModel, Codable {

    var id: Int64
    var athleteID: String?
    var trainerID: String?
    var date: Date?
    var treatment: String?
    var info: String?
    var injury: String?

    enum codingKeys: String, CodingKey {
        case id
        case athleteID
        case trainerID
        case date
        case treatment
        case info
        case injury
    }

    func encode(to: Encoder) throws {
        var container = to.container(keyedBy: codingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encodeIfPresent(athleteID, forKey: .athleteID)
        try container.encodeIfPresent(trainerID, forKey: .trainerID)
        try container.encodeIfPresent(date?.iso8601String, forKey: .date)
        try container.encodeIfPresent(treatment, forKey: .treatment)
        try container.encodeIfPresent(info, forKey: .info)
        try container.encodeIfPresent(injury, forKey: .injury)
    }

}
