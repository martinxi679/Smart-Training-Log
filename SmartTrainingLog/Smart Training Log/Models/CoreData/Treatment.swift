//
//  Treatment.swift
//  Smart Training Log
//
//  Created by Kasper Gammeltoft on 9/25/18.
//  Copyright © 2018 CS4261. All rights reserved.
//

import Foundation
import CoreData

extension Treatment {

    static func fetchOrCreate(id: Int64) -> Treatment {
        return fetchOrCreate(id: Int(id))
    }

    static func fetchOrCreate(id: Int) -> Treatment {

        let fetchRequest = NSFetchRequest<Treatment>()
        fetchRequest.predicate = NSPredicate(format: "id == %l", id)

        if
            let results = try? fetchRequest.execute(),
            let result = results.first {
            return result
        } else {
            let treatment = Treatment()
            treatment.id = Int64(id)
            return treatment
        }
    }
}

extension Treatment: TreatmentModel {}
