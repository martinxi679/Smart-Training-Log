//
//  TreatmentModel.swift
//  Smart Training Log
//
//  Created by Kasper Gammeltoft on 9/25/18.
//  Copyright © 2018 CS4261. All rights reserved.
//

import Foundation

protocol TreatmentModel {

    var id: Int64 {get set}
    var athleteID: String? {get set}
    var trainerID: String? {get set}
    var date: Date? {get set}
    var treatment: String? {get set}
    var info: String? {get set}
    var injury: String? {get set}

}

enum TreatmentType: String {
    case massage = "Massage"
    case medication = "Medication"
    case physicalTherapy = "Physical Therapy"
}

enum Injury: String {
    case concussion = "Concussion"
    case ankleSprain = "Sprained Ankle"
}

extension TreatmentModel {
    func getTreatmentType() -> TreatmentType? {
        return TreatmentType(rawValue: self.treatment ?? "")
    }

    func getInjury() -> Injury? {
        return Injury(rawValue: injury ?? "")
    }

    func getID() -> Int64 {
        guard
            let athleteID = athleteID?.hashValue,
            let trainerID = trainerID?.hashValue,
            let date = date?.hashValue,
            let treatment = treatment?.hashValue
            else {
                return 0
        }
        return Int64(athleteID ^ trainerID ^ date ^ treatment)
    }
}

extension TreatmentModel {
    mutating func update(with model: TreatmentModel) {
        id = model.id
        athleteID = model.athleteID ?? athleteID
        trainerID = model.trainerID ?? trainerID
        date = model.date ?? date
        treatment = model.treatment ?? treatment
        info = model.info ?? info
        injury = model.injury ?? injury
    }
}
