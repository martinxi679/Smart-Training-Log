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

    let queue = DispatchQueue(label: "treatments arr queue")

    override init() {
        super.init()

        athleteViewModel.refreshed.observe({ [weak self] (_,_) in
            self?.update()
        }).add(to: &disposeBag)

        update()
    }

    func update() {
        guard let dataManager = try? Container.resolve(DatabaseManager.self) else { return }
        let athletes = athleteViewModel.allAthletes

        for athlete in athletes {
            if let id = athlete.id {
                queue.sync {
                    dataManager.getTreatments(forUserID: id, completionHandler: {[weak self] (models) in
                        guard let strongSelf = self else { return }
                        strongSelf.treatments.append(contentsOf: models)
                        strongSelf.refreshed.value = true
                    })
                }
            }
        }
    }

    func athleteForID(id: String) -> StudentModel? {
        return athleteViewModel.allAthletes.first(where: { $0.id == id })
    }

    func numberOfSections() -> Int {
        return 1
    }

    func numberOfTreatments(in section: Int) -> Int {
        return treatments.count
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
