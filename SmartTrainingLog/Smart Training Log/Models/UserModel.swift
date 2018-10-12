//
//  UserModel.swift
//  Smart Training Log
//

import UIKit

protocol UserModel {

    var uid: String? { get set }
    var name: String? { get set }
    var photoURL: String? { get set }
    var sport: String? { get set }
    var entitlement: String? { get set }
    var injury: String? { get set }
    var trainerModel: UserModel? { get set }
    var athletes: NSSet? { get set }

}

extension UserModel {

    func getSport() -> Sport? {
        return Sport(rawValue: sport ?? "")
    }

    func getEntitlement() -> Entitlement? {
        return Entitlement(rawValue: entitlement ?? "")
    }

    func getPhotoURL() -> URL? {
        if let urlStr = photoURL {
            return URL(string: urlStr)
        }
        return nil
    }

    func getInjury() -> Injury? {
        return Injury(rawValue: injury ?? "")
    }

    func getAthletes() -> [UserModel] {
        guard let athleteModels = athletes else { return [] }
        return athleteModels.allObjects as! [UserModel]
    }

    func getProfileImage(handler: @escaping (UIImage?) -> Void) {
        guard let storageManager = try? Container.resolve(CloudStorageManager.self) else { return }
        guard let urlStr = photoURL,
            let url = URL(string: urlStr) else { return }
        storageManager.getProfilePicture(url: url , handler: handler)
    }

}

extension UserModel {
    mutating func update(with model: UserModel) {
        self.name = model.name ?? self.name
        self.uid = model.uid ?? self.uid
        self.photoURL = model.photoURL ?? self.photoURL
        self.sport = model.sport ?? self.sport
        self.entitlement = model.entitlement ?? self.entitlement
        self.injury = model.injury ?? self.injury
        self.trainerModel = model.trainerModel ?? self.trainerModel
    }
}
