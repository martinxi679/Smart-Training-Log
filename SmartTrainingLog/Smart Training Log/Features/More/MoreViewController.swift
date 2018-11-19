//
//  MoreViewController.swift
//  Smart Training Log
//

import UIKit

class MoreViewController: UIViewController {

    struct Identifiers {
        enum Segue: String {
            case backToLoginSegue
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        //setup
    }

    @IBAction func logoutPressed(_ sender: Any) {
        logout()
    }

    // MARK: - Private
    private func logout() {
        guard let authStore = try? Container.resolve(AuthenticationStore.self) else { return }

        authStore.logout()
        self.performSegue(withIdentifier: Identifiers.Segue.backToLoginSegue.rawValue, sender: self)
    }
}
