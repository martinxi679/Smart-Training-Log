//
//  UserFlyweight.swift
//  Smart Training Log
//

import Foundation

struct UserFlyweight: UserModel, Codable {

    var uid: String?
    var name: String?
    var photoURL: String?
    var sport: String?
    var entitlement: String?
    var injury: String?
    var trainerModel: UserModel?
    var athletes: NSSet?

    enum CodingKeys: String, CodingKey {
        case uid
        case name
        case photoURL
        case sport
        case entitlement
        case injury
        case trainer
        case athletes
    }

    init(uid: String) {
        self.uid = uid
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        uid = try container.decode(String.self, forKey: .uid)
        name = try container.decodeIfPresent(String.self, forKey: .name)
        photoURL = try container.decodeIfPresent(String.self, forKey: .photoURL)
        sport = try container.decodeIfPresent(String.self, forKey: .sport)
        entitlement = try container.decodeIfPresent(String.self, forKey: .entitlement)
        injury = try container.decodeIfPresent(String.self, forKey: .injury)
        
        if let trainerID = try container.decodeIfPresent(String.self, forKey: .trainer) {
            trainerModel = UserFlyweight(uid: trainerID)
        }

        if let athleteArr = try container.decodeIfPresent([String].self, forKey: .athletes) {
            var athleteModels: [UserModel] = []
            for athleteID in athleteArr {
                athleteModels.append(UserFlyweight(uid: athleteID))
            }
            athletes = NSSet(array: athleteModels)
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(uid!, forKey: .uid)
        try container.encodeIfPresent(name, forKey: .name)
        try container.encodeIfPresent(sport, forKey: .sport)
        try container.encodeIfPresent(entitlement, forKey: .entitlement)
        try container.encodeIfPresent(injury, forKey: .injury)
        if let model = trainerModel as? UserFlyweight {
            try container.encodeIfPresent(model.uid, forKey: .trainer)
        }

        var athleteFlyweights: [String?] = []

        if let athletes = self.athletes {
            for value in athletes where value is UserFlyweight {
                athleteFlyweights.append((value as! UserFlyweight).uid)
            }
        }

        try container.encode(athleteFlyweights.compactMap({return $0}), forKey: .athletes)
    }

}
