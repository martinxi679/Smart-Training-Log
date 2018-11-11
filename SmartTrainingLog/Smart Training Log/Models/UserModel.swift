//
//  UserModel.swift
//  Smart Training Log
//

import UIKit
import FirebaseAuth

protocol UserModel {

    var name: String? { get set }
    var id: String? { get set }
    var authUser: User? { get set }
    var entitlement: Entitlement? { get set }
}

extension UserModel {

    var isTrainer: Bool {
        get {
            guard let type = entitlement else { return false }
            return type == .trainer
        }
    }

    var isAthlete: Bool {
        get {
            guard let type = entitlement else { return false }
            return type == .student
        }
    }

    func getProfileImage(handler: @escaping (UIImage?) -> Void) {
        guard let storageManager = try? Container.resolve(CloudStorageManager.self) else { return }
        guard let url = storageManager.getProfileImageURL(user: self) else { return }

        storageManager.getProfilePicture(url: url , handler: handler)
    }

}

extension UserModel {
    mutating func update(with model: UserModel) {
        self.name = model.name ?? self.name
        self.id = model.id ?? self.id
        self.authUser = model.authUser ?? self.authUser
        self.entitlement = model.entitlement ?? self.entitlement
    }
}
