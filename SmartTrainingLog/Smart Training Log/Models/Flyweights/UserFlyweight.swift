//
//  UserFlyweight.swift
//  Smart Training Log
//

import Foundation
import FirebaseAuth

struct UserFlyweight: StudentModel & TrainerModel, Codable {

    // Athlete
    var year: Int?
    var sport: Sport?
    var injury: Injury?
    var trainer: TrainerModel?
    var dob: Date?

    // Trainer
    var athletes: [StudentModel] = []
    var teams: [String] = []

    // User
    var authUser: User?
    var entitlement: Entitlement?
    var name: String?
    var id: String?
    var deviceToken: String?

    enum CodingKeys: String, CodingKey {
        case id
        case deviceID
        case name
        case sport
        case entitlement
        case injury
        case trainer
        case athletes
        case year
        case teams
    }

    init(id: String) {
        self.id = id
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(String.self, forKey: .id)
        deviceToken = try container.decodeIfPresent(String.self, forKey: .deviceID)
        name = try container.decodeIfPresent(String.self, forKey: .name)
        if let sportStr = try container.decodeIfPresent(String.self, forKey: .sport) {
            sport = Sport(rawValue: sportStr)
        }
        if let entitlementStr = try container.decodeIfPresent(String.self, forKey: .entitlement) {
            entitlement = Entitlement(rawValue: entitlementStr)
        }
        if let injuryStr = try container.decodeIfPresent(String.self, forKey: .injury) {
            injury = Injury(rawValue: injuryStr)
        }
        
        if let trainerID = try container.decodeIfPresent(String.self, forKey: .trainer) {
            trainer = UserFlyweight(id: trainerID)
        }

        if let athleteArr = try container.decodeIfPresent([String].self, forKey: .athletes) {
            var athleteModels: [UserFlyweight] = []
            for athleteID in athleteArr {
                athleteModels.append(UserFlyweight(id: athleteID))
            }
            athletes = athleteModels
        } else if let athleteDict = try container.decodeIfPresent([String: String].self, forKey: .athletes) {
            var athleteModels: [UserFlyweight] = []
            for athleteID in athleteDict.values {
                athleteModels.append(UserFlyweight(id: athleteID))
            }
            athletes = athleteModels
        } else if let athleteID = try container.decodeIfPresent(String.self, forKey: .athletes) {
            athletes = [UserFlyweight(id: athleteID)]
        }

        if let teamsArr = try container.decodeIfPresent([String].self, forKey: .teams) {
            teams = teamsArr
        } else if let teamsDict = try container.decodeIfPresent([String:String].self, forKey: .teams) {
            teams = teamsDict.map({return $1})
        } else if let team = try container.decodeIfPresent(String.self, forKey: .teams) {
            teams = [team]
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id!, forKey: .id)
        try container.encodeIfPresent(deviceToken, forKey: .deviceID)
        try container.encodeIfPresent(name, forKey: .name)
        try container.encodeIfPresent(sport?.rawValue, forKey: .sport)
        try container.encodeIfPresent(entitlement?.rawValue, forKey: .entitlement)
        try container.encodeIfPresent(injury?.rawValue, forKey: .injury)
        if let model = trainer as? UserFlyweight {
            try container.encodeIfPresent(model.id, forKey: .trainer)
        }

        var athleteFlyweights: [String?] = []

        for value in athletes {
            athleteFlyweights.append(value.id)
        }

        try container.encode(athleteFlyweights.compactMap({return $0}), forKey: .athletes)
        try container.encode(teams, forKey: .teams)
    }
}
