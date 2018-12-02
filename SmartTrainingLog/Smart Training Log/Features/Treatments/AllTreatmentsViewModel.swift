//
//  AllTreatmentsViewModel.swift
//  Smart Training Log
//

import Observable

class AllTreatmentsViewModel: NSObject {


    var refreshed: Observable<Bool> = Observable(false)

    var treatments: [TreatmentModel] = []

    var disposeBag: Disposal = []
    var athleteViewModel = AllAthletesViewModel()
    var athlete: UserFlyweight? {
        didSet {
            update()
        }
    }

    let queue = DispatchQueue(label: "treatments arr queue")

    init(athlete: UserFlyweight) {
        super.init()
        self.athlete = athlete
        update()
    }

    override init() {
        super.init()

        athleteViewModel.refreshed.observe({ [weak self] (_,_) in
            self?.update()
        }).add(to: &disposeBag)
        update()
    }

    func update(resetCache: Bool = false) {
        if resetCache {
            queue.sync {
                treatments.removeAll()
            }
        }

        guard let dataManager = try? Container.resolve(DatabaseManager.self) else { return }
        var athletes = athleteViewModel.allAthletes()

        if self.athlete != nil {
            athletes = [self.athlete!]
        }

        for athlete in athletes {
            if let id = athlete.id?.sha256() {
                dataManager.getTreatments(forUserID: id, completionHandler: {[weak self] (models) in
                    guard let strongSelf = self else { return }
                    for model in models {
                        strongSelf.queue.sync {
                            if !strongSelf.treatments.contains(where: {$0.id == model.id }) {
                                strongSelf.treatments.append(model)
                            }
                        }
                    }
                    strongSelf.refreshed.value = true
                })
            }
        }
    }

    func getAllTreatments() -> [TreatmentModel] {
        var retVal: [TreatmentModel] = []
        queue.sync {
            retVal.append(contentsOf: treatments)
        }
        return retVal
    }
    
    func getPastTreatments() -> [TreatmentModel] {
        let currentDate = Date()
        let allTreatments = getAllTreatments()
        return allTreatments.filter ({(treatment) in
            if let date = treatment.date {
                return date < currentDate
            } else {
                return false
            }
        }).sorted(by: { return $0.date! < $1.date! })
    }

    func getUpcomingTreatments() -> [TreatmentModel] {
        let currentDate = Date()
        let allTreatments = getAllTreatments()
        return allTreatments.filter ({ (treatment) in
            if let date = treatment.date {
                return date >= currentDate
            } else {
                return false
            }
        }).sorted(by: { return $0.date! < $1.date! })
    }

    func athleteForID(id: String) -> StudentModel? {
        return athleteViewModel.allAthletes().first(where: { $0.id?.sha256() == id })
    }

    func numberOfSections() -> Int {
        return 1
    }

    func numberOfTreatments(in section: Int) -> Int {
        var count = 0
        queue.sync {
            count = treatments.count
        }
        return count
    }

    func treatment(atIndexPath indexPath: IndexPath) -> TreatmentModel? {
        let index = indexPath.row
        var treatment: TreatmentModel?
        queue.sync {
            if index < treatments.count {
                treatment = treatments[index]
            }
        }
        return treatment
    }
}

class UpcomingTreatmentsViewModel: AllTreatmentsViewModel {

    override func numberOfSections() -> Int {
        return 1
    }

    override func numberOfTreatments(in section: Int) -> Int {
        return getUpcomingTreatments().count
    }

    override func treatment(atIndexPath indexPath: IndexPath) -> TreatmentModel? {
        let upcoming = getUpcomingTreatments()
        guard indexPath.row < upcoming.count else { return nil }
        return upcoming[indexPath.row]
    }
}

class PastTreatmentsViewModel: AllTreatmentsViewModel {

    override func numberOfSections() -> Int {
        return 1
    }

    override func numberOfTreatments(in section: Int) -> Int {
        return getPastTreatments().count
    }

    override func treatment(atIndexPath indexPath: IndexPath) -> TreatmentModel? {
        let past = getPastTreatments()
        guard indexPath.row < past.count else { return nil }
        return past[indexPath.row]
    }
}
