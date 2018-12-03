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
    var complete: Bool? = false
    var checkin: Bool? = false
    var comments: [CommentModel] = []

    enum CodingKeys: String, CodingKey {
        case id
        case athleteID
        case trainerID
        case date
        case treatment
        case info
        case complete
        case checkin
        case comments
    }

    init(id: String? = nil) {
        self.id = id
    }


    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        athleteID = try container.decodeIfPresent(String.self, forKey: .athleteID)
        trainerID = try container.decodeIfPresent(String.self, forKey: .trainerID)
        if let dateStr = try container.decodeIfPresent(String.self, forKey: .date) {
            date = Date.dateFromISO8601String(dateStr)
        }
        treatment = try container.decodeIfPresent(String.self, forKey: .treatment)
        info = try container.decodeIfPresent(String.self, forKey: .info)
        complete = (try container.decodeIfPresent(Bool.self, forKey: .complete)) ?? false
        checkin = (try container.decodeIfPresent(Bool.self, forKey: .checkin)) ?? false
        if let commentsArr = try container.decodeIfPresent([CommentFlyweight].self, forKey: .comments) {
            comments = commentsArr
        } else if let commentsDict = try container.decodeIfPresent([String: CommentFlyweight].self, forKey: .comments) {
            comments = commentsDict.map({return $1})
        } else if let comment = try container.decodeIfPresent(CommentFlyweight.self, forKey: .comments) {
            comments = [comment]
        }
    }

    func encode(to: Encoder) throws {
        var container = to.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encodeIfPresent(athleteID, forKey: .athleteID)
        try container.encodeIfPresent(trainerID, forKey: .trainerID)
        try container.encodeIfPresent(date?.iso8601String, forKey: .date)
        try container.encodeIfPresent(treatment, forKey: .treatment)
        try container.encodeIfPresent(info, forKey: .info)
        try container.encodeIfPresent(complete, forKey: .complete)
        try container.encodeIfPresent(checkin, forKey: .checkin)
        try container.encodeIfPresent(comments as? [CommentFlyweight], forKey: .comments)
    }
}
