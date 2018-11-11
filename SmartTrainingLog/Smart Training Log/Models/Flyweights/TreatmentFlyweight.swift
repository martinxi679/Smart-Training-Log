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
    var complete: Bool?

    enum codingKeys: String, CodingKey {
        case id
        case athleteID
        case trainerID
        case date
        case treatment
        case info
        case complete
    }

    init(id: String? = nil) {
        self.id = id
    }

    init(decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: codingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        athleteID = try container.decode(String.self, forKey: .athleteID)
        trainerID = try container.decode(String.self, forKey: .trainerID)
        if let dateStr = try container.decodeIfPresent(String.self, forKey: .date) {
            date = Date.dateFromISO8601String(dateStr)
        }
        treatment = try container.decodeIfPresent(String.self, forKey: .treatment)
        info = try container.decodeIfPresent(String.self, forKey: .info)
        complete = try container.decode(Bool.self, forKey: .complete)
    }

    func encode(to: Encoder) throws {
        var container = to.container(keyedBy: codingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encodeIfPresent(athleteID, forKey: .athleteID)
        try container.encodeIfPresent(trainerID, forKey: .trainerID)
        try container.encodeIfPresent(date?.iso8601String, forKey: .date)
        try container.encodeIfPresent(treatment, forKey: .treatment)
        try container.encodeIfPresent(info, forKey: .info)
        try container.encodeIfPresent(complete, forKey: .complete)
    }
}
