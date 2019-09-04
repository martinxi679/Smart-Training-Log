//
//  AdminProfileViewController.swift
//  Smart Training Log
//  Admin profile view: load Email, Email text edit, Button pressed

import UIKit

class AdminProfileViewController: UIViewController {


    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var teamsPickerView: UIPickerView!
    @IBOutlet weak var saveButton: RoundRectButton!

    var teams: [String] = []

    var queue: DispatchQueue = DispatchQueue(label: "Admin profile teams queue")

    var currentTeam: String? {
        didSet {
            if isViewLoaded {
                loadEmail()
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        guard let admin = (try? Container.resolve(AuthenticationStore.self))?.currentUser as? UserFlyweight else { return }

        guard let manager = try? Container.resolve(DatabaseManager.self) else { return }

        for team in admin.teams {
            manager.getAdminStatus(admin, forTeam: team, completion: { [weak self] isAdmin in
                guard isAdmin else { return }
                guard let strongSelf = self else { return }

                strongSelf.queue.sync {
                    strongSelf.teams.append(team)
                }

                if strongSelf.currentTeam == nil {
                    strongSelf.currentTeam = team
                }

                strongSelf.teamsPickerView.reloadComponent(0)
            })
        }

        loadEmail()
    }

    private func loadEmail() {
        guard let team = currentTeam else { return }
        (try? Container.resolve(DatabaseManager.self))?.getTeamEmail(team, completion: {[weak self] email in
            self?.emailTextField.text = email
        })
    }

    @IBAction func emailTextFieldEdited(_ sender: Any) {
        configureSaveButton()
    }

    @IBAction func saveButtonPressed(_ sender: Any) {
        saveAccountEmail()
    }

    private func configureSaveButton() {
        if let email = emailTextField.text,
            email.isValidEmail {
            saveButton.isEnabled = true
        } else {
            saveButton.isEnabled = false
        }
    }

    private func saveAccountEmail() {
        guard let email = emailTextField.text else { return }
        guard email.isValidEmail else { return }
        guard let team = currentTeam else { return }

        (try? Container.resolve(DatabaseManager.self))?.updateTeamEmail(email, forTeam: team)

        navigationController?.popViewController(animated: true)
    }
}

extension AdminProfileViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        saveAccountEmail()
        return saveButton.isEnabled
    }
}

extension AdminProfileViewController: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        var count = 0
        queue.sync {
            count = teams.count
        }
        return count
    }
}

extension AdminProfileViewController: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        var team: String = ""
        queue.sync {
            team = teams[row]
        }

        return team
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        var team: String = ""
        queue.sync {
            team = teams[row]
        }

        currentTeam = team
    }
}
