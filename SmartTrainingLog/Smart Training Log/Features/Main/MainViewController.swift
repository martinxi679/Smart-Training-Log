//
//  MainViewController.swift
//  Smart Training Log
//

import UIKit

class MainViewController: UITabBarController {

    var currentTreatment: TreatmentModel?

    override func viewDidLoad() {
        super.viewDidLoad()

        if let user = (try? Container.resolve(AuthenticationStore.self))?.currentUser {
            if user.entitlement == Entitlement.admin {
                //Add admin tab
                let adminStoryboard = UIStoryboard(name: "AdminMain", bundle: nil)
                if let adminVC = adminStoryboard.instantiateInitialViewController() {
                    viewControllers?.insert(adminVC, at: 0)
                }
            }

            guard let dataManager = try? Container.resolve(DatabaseManager.self) else { return }
            guard let id = user.id?.sha256() else { return }

            dataManager.getTreatments(forUserID: id, completionHandler: { [weak self] treatments in
                if let current = treatments.first(where: { ($0.date?.isWithinSeconds(60 * 5) ?? false) && !($0.complete ?? false) }) {
                    self?.currentTreatment = current
                }
            })
        }
    }
}
