//
//  AllAthletesViewModel.swift
//  Smart Training Log
//

import Foundation
import Observable

class AllAthletesViewModel: NSObject {

    var refreshed: Observable<Bool> = Observable(false)

    var athletes: [String: [StudentModel]] = [:]
    var queue = DispatchQueue(label: "Athlete dict queue")

    override init() {
        super.init()

        update()
    }

    func update() {
        guard let user = (try? Container.resolve(AuthenticationStore.self))?.currentUser else { return }
        guard let dataManager = try? Container.resolve(DatabaseManager.self) else {
            return
        }

        if user.isTrainer {
            guard let trainer = user as? TrainerModel else { return }
            for team in trainer.teams {
                dataManager.getAthletes(team: team, trainer: trainer as! UserFlyweight, completion: { [weak self] (students) in
                    guard let strongSelf = self else { return }
                    guard students.count > 0 else { return }

                    strongSelf.queue.sync {
                        strongSelf.athletes[team] = students
                    }
                    DispatchQueue.main.async {
                        strongSelf.refreshed.value = true
                    }
                })
            }
        } else {
            if let student = user as? UserFlyweight,
                let team = student.teams.first {
                self.queue.sync {
                    athletes[team] = [student]
                }
            }
        }
    }

    func athleteByID(_ id: String) -> StudentModel? {
        return allAthletes().first(where: {$0.id == id})
    }

    func athleteByHashID(_ hashID: String) -> StudentModel? {
        return allAthletes().first(where: {$0.id?.sha256() == hashID })
    }

    func numberOfAthletes(_ team: String) -> Int {
        var num = 0
        queue.sync {
            num = athletes[team]?.count ?? 0
        }
        return num
    }

    func teamForSection(_ section: Int) -> String {
        var team: String = ""
        guard !athletes.keys.isEmpty else { return ""}
        queue.sync {
            team = athletes.keys[athletes.keys.index(athletes.keys.startIndex, offsetBy: section)]
        }
        return team
    }

    func athlete(for indexPath: IndexPath) -> UserModel? {
        let team = teamForSection(indexPath.section)
        var athlete: UserModel?
        queue.sync {
            athlete = athletes[team]?[indexPath.row]
        }

        return athlete
    }

    func numberOfSections() -> Int {
        var section = 0
        queue.sync {
            section = athletes.keys.count
        }
        return section
    }

    func numberOfRows(in section: Int) -> Int {
        let team = teamForSection(section)
        var row = 0
        queue.sync {
            row = athletes[team]?.count ?? 0
        }
        return row
    }

    func allAthletes() -> [StudentModel] {
        var athleteModels: [StudentModel] = []
        queue.sync {
            for key in athletes.keys {
                if let val = athletes[key] {
                    athleteModels.append(contentsOf: val)
                }
            }
        }
        return athleteModels
    }
}
