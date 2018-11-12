//
//  CommentFlyweight.swift
//  Smart Training Log
//

import Foundation

struct CommentFlyweight: CommentModel, Codable {
    
    var id: String?
    var trainerID: String?
    var date: Date?
    var content: String?
    
    enum codingKeys: String, CodingKey {
        case id
        case trainerID
        case date
        case content
    }
    
    init(id: String? = nil) {
        self.id = id
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: codingKeys.self)
        id = try container.decodeIfPresent(String.self, forKey: .id)
        trainerID = try container.decodeIfPresent(String.self, forKey: .trainerID)
        if let dateStr = try container.decodeIfPresent(String.self, forKey: .date) {
            date = Date.dateFromISO8601String(dateStr)
        }
        content = try container.decodeIfPresent(String.self, forKey: .content)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: codingKeys.self)
        try container.encodeIfPresent(id, forKey: .id)
        try container.encodeIfPresent(trainerID, forKey: .trainerID)
        try container.encodeIfPresent(date?.iso8601String, forKey: .date)
        try container.encodeIfPresent(content, forKey: .content)
    }
}
