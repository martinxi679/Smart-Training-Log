//
//  CommentFlyweight.swift
//  Smart Training Log
//
//  Created by Alice Lew on 11/11/18.
//  Copyright © 2018 CS4261. All rights reserved.
//

import Foundation

struct CommentFlyweight: CommentModel, Codable {
    
    var id: String?
    var athleteID: String?
    var trainerID: String?
    var date: Date?
    var content: String?
    
    enum codingKeys: String, CodingKey {
        case id
        case athleteID
        case trainerID
        case date
        case content
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
        content = try container.decodeIfPresent(String.self, forKey: .content)
    
    func encode(to: Encoder) throws {
        var container = to.container(keyedBy: codingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encodeIfPresent(athleteID, forKey: .athleteID)
        try container.encodeIfPresent(trainerID, forKey: .trainerID)
        try container.encodeIfPresent(date?.iso8601String, forKey: .date)
        try container.encodeIfPresent(content, forKey: .content)
    }
    }
}
