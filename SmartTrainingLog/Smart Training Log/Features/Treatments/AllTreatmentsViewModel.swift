//
//  AllTreatmentsViewModel.swift
//  Smart Training Log
//

import Observable

class AllTreatmentsViewModel: NSObject {


    var refreshed: Observable<Bool> = Observable(false)

    override init() {
        super.init()

        guard let user = (try? Container.resolve(AuthenticationStore.self))?.currentUser else { return }

        let athleteModel = AllAthletesViewModel()
        

    }
}
