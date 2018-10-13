//
//  UserInfo.swift
//  Smart Training Log
//

import UIKit
import CoreData

extension UserInfo {

    static func fetchOrCreate(uid: String) -> UserInfo {
        let request: NSFetchRequest<UserInfo> = UserInfo.fetchRequest()
        request.predicate = NSPredicate(format: "uid = %@", uid)

        if let info = try? request.execute(),
            let userInfo = info.first {
            return userInfo
        } else {
            guard let context = (try? Container.resolve(PersistenceManager.self))?.persistentContainer.viewContext else { return UserInfo() }
            let userInfo = UserInfo(context: context)
            userInfo.uid = uid
            return userInfo
        }
    }

    static func fetchRequest(uid: String) -> NSFetchRequest<UserInfo> {
        let request: NSFetchRequest<UserInfo> = UserInfo.fetchRequest()
        request.predicate = NSPredicate(format: "uid = %@", uid)
        return request
    }

}

extension UserInfo: UserModel {
    var trainerModel: UserModel? {
        get {
            return trainer
        }
        set {
            if
                let model = trainerModel,
                let id = model.uid {
                self.trainer = UserInfo.fetchOrCreate(uid: id)
                self.trainer?.update(with: model)
            }
        }
    }

//    var athleteModels: [UserModel]? {
//        get {
//            return athletes?.allObjects as? [UserModel]
//        }
//        set {
//            if let models = athleteModels {
//                for model in models {
//                    if let athleteID = model.uid {
//                        var athlete = UserInfo.fetchOrCreate(uid: athleteID)
//                        athlete.update(with: model)
//                        addToAthletes(athlete)
//                    }
//                }
//            }
//        }
//    }
}
