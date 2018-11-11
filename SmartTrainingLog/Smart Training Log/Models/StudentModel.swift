//
//  StudentModel.swift
//  Smart Training Log
//

import Foundation
import UIKit
import FirebaseAuth

protocol StudentModel: UserModel {
    var year: Int? { get set }
    var sport: Sport? { get set }
    var injury: Injury? { get set }
    var trainer: TrainerModel? { get set }
}

extension StudentModel {
    mutating func update(with model: StudentModel) {
        self.name = model.name ?? self.name
        self.id = model.id ?? self.id
        self.entitlement = model.entitlement ?? self.entitlement
        self.authUser = model.authUser ?? self.authUser
        self.injury = model.injury ?? self.injury
        self.sport = model.sport ?? self.sport
        self.year = model.year ?? self.year
    }
}
