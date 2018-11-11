//
//  TrainerModel.swift
//  Smart Training Log
//

import Foundation

protocol TrainerModel: UserModel {
    var athletes: [StudentModel] { get set }
    var teams: [String] { get set }
}

extension TrainerModel {
    mutating func update(with model: TrainerModel) {
        self.name = model.name ?? self.name
        self.id = model.id ?? self.id
        self.athletes = model.athletes.isEmpty ? self.athletes : model.athletes
        self.entitlement = model.entitlement ?? self.entitlement
        self.authUser = model.authUser ?? self.authUser
        self.teams = model.teams.isEmpty ? self.teams : model.teams
    }
}
