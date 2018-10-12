//
//  TreatmentModel.swift
//  Smart Training Log
//

import Foundation

protocol TreatmentModel {

    var id: String? {get set}
    var athleteID: String? {get set}
    var trainerID: String? {get set}
    var date: Date? {get set}
    var treatment: String? {get set}
    var info: String? {get set}

}

enum TreatmentType: String {
    case massage = "Massage"
    case medication = "Medication"
    case physicalTherapy = "Physical Therapy"
    case otherTreatment = "Other Treatment"
}

enum Injury: String {
    case concussion = "Concussion"
    case ankleSprain = "Sprained Ankle"
}

extension TreatmentModel {
    func getTreatmentType() -> TreatmentType? {
        return TreatmentType(rawValue: self.treatment ?? "")
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
    }
}
