//
//  RequestTeamViewController.swift
//  Smart Training Log
//

import UIKit

class RequestTeamViewController: UIViewController {

    @IBOutlet var requestTeamTextField: UITextField!
    @IBOutlet weak var requestButton: RoundRectButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        // setup
        requestButton.isEnabled = false
        requestTeamTextField.delegate = self
    }

    @IBAction func userDidTap(_ sender: Any) {
        view.endEditing(true)
    }

    @IBAction func textFieldEditingChanged(_ sender: Any) {
        requestButton.isEnabled = requestTeamTextField.text != nil && requestTeamTextField.text != ""
    }

    @IBAction func requestPressed(_ sender: Any) {
        requestTeam()
    }

    private func requestTeam() {
        // TODO - implement team request

        self.navigationController?.popViewController(animated: true)
    }
}

extension RequestTeamViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if requestButton.isEnabled {
            requestTeam()
        }
        return true
    }
}
