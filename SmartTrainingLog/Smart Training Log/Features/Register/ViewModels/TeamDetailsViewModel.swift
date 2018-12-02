//
//  TeamDetailsViewModel.swift
//  Smart Training Log
//

import Foundation
import Observable

class TeamDetailsViewModel {

    var teamID: String {
        didSet {
            update()
        }
    }
    var athletes: [StudentModel] = []
    let updated: Observable<Bool> = Observable(false)

    init(_ teamID: String) {
        self.teamID = teamID
        update()
    }

    func update() {
        guard let dataManager = try? Container.resolve(DatabaseManager.self) else { return }
        guard let trainer = (try? Container.resolve(AuthenticationStore.self))?.currentUser as? UserFlyweight else { return }

    dataManager.getAthletes(team: teamID, trainer: trainer, completion: { [weak self] students in
        self?.athletes = students
        self?.updated.value = true
    })
    }
}
