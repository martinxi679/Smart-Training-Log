//
//  GetUserOperation.swift
//  Smart Training Log
//

import Foundation

class GetUserOperation: Operation {

    var user: UserFlyweight

    init(userToFetch user: UserFlyweight) {
        self.user = user
    }

    override func execute() {
        guard let dbManager = try? Container.resolve(DatabaseManager.self) else { return }
        guard let id = user.uid else { return }
        dbManager.getUser(uid: id, onCompletion: { [weak self] in
            dbManager.getTreatment(completionHandler: {
                self?.finish()
            })
        })
    }


}
