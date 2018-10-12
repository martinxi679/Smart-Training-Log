//
//  TreatmentFlyweight.swift
//  Smart Training Log
//

import Foundation

struct TreatmentFlywieght: TreatmentModel, Codable {

    var id: String?
    var athleteID: String?
    var trainerID: String?
    var date: Date?
    var treatment: String?
    var info: String?

    enum codingKeys: String, CodingKey {
        case id
        case athleteID
        case trainerID
        case date
        case treatment
        case info
    }

    init(id: String? = nil) {
        self.id = id
    }

    func encode(to: Encoder) throws {
        var container = to.container(keyedBy: codingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encodeIfPresent(athleteID, forKey: .athleteID)
        try container.encodeIfPresent(trainerID, forKey: .trainerID)
        try container.encodeIfPresent(date?.iso8601String, forKey: .date)
        try container.encodeIfPresent(treatment, forKey: .treatment)
        try container.encodeIfPresent(info, forKey: .info)
    }

}
