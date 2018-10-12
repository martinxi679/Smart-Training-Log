//
//  Treatment.swift
//  Smart Training Log
//

import Foundation
import CoreData
import FirebaseAuth

extension Treatment {

    static func fetchOrCreate(id: String) -> Treatment {

        let fetchRequest: NSFetchRequest<Treatment> = Treatment.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", id)

        if
            let results = try? fetchRequest.execute(),
            let result = results.first {
            return result
        } else {
            guard let context = (try? Container.resolve(PersistenceManager.self))?.persistentContainer.viewContext else { return Treatment() }
            let treatment = Treatment(context: context)
            treatment.id = id
            return treatment
        }
    }

    static func allTreatmentsRequest(for user: UserModel) -> NSFetchRequest<Treatment> {
        let fetchRequest = NSFetchRequest<Treatment>()
        guard let id = user.uid else { return fetchRequest }
        let athletePredicate = NSPredicate(format: "athleteID == %@", id)
        let trainerPredicate = NSPredicate(format: "trainerID == %@", id)

        fetchRequest.predicate = NSCompoundPredicate(orPredicateWithSubpredicates: [athletePredicate, trainerPredicate])
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]
        return fetchRequest
    }
}

extension Treatment: TreatmentModel {}
