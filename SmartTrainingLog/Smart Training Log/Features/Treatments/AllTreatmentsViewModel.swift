//
//  AllTreatmentsViewModel.swift
//  Smart Training Log
//

import Foundation
import CoreData
import Observable

class AllTreatmentsViewModel: NSObject {

    private var resultsController: NSFetchedResultsController<Treatment>?
    private var athleteController: NSFetchedResultsController<UserInfo>?

    var refreshed: Observable<Bool> = Observable(false)

    override init() {
        super.init()

        guard let user = (try? Container.resolve(AuthenticationStore.self))?.user else { return }
        guard let persistenceManager = try? Container.resolve(PersistenceManager.self) else { return }
        let request = Treatment.allTreatmentsRequest(for: user)
        resultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: persistenceManager.persistentContainer.viewContext, sectionNameKeyPath: nil, cacheName: nil)

        resultsController?.delegate = self
        try? resultsController?.performFetch()

        let athleteRequest: NSFetchRequest<UserInfo> = UserInfo.fetchRequest()
        athleteController = NSFetchedResultsController(fetchRequest: athleteRequest, managedObjectContext: persistenceManager.persistentContainer.viewContext, sectionNameKeyPath: nil, cacheName: nil)

        try? athleteController?.performFetch()
    }

    func numberOfSections() -> Int {
        return 1
    }

    func numberOfRows(in section: Int) -> Int {
        return resultsController?.fetchedObjects?.count ?? 0
    }

    func treatment(for index: IndexPath) -> TreatmentModel? {
        let index = index.item
        guard index < numberOfRows(in: 0) else { return nil }
        if let treatment = resultsController?.fetchedObjects?[index] {
            var newTreatment = TreatmentFlywieght(id: treatment.id!)
            newTreatment.update(with: treatment)
            return newTreatment
        } else {
            return nil
        }
    }

    func athlete(id: String?) -> UserModel? {
        guard let id = id else { return nil }
        if let athletes = athleteController?.fetchedObjects {
            for athlete in athletes where athlete.uid == id {
                var model = UserFlyweight(uid: id)
                model.update(with: athlete)
                return athlete
            }
        }
        return nil
    }

    private func update() {
        refreshed.value = true
    }

}

extension AllTreatmentsViewModel: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        update()
    }
}
