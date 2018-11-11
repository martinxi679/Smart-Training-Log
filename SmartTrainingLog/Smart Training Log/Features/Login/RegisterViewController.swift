//
//  RegisterViewController.swift
//  Smart Training Log
//

import UIKit
import FirebaseAuth

class RegisterViewController: UIViewController {

    struct Identifiers {
        enum Segue: String {
            case toMain = "registerToMain"
        }
    }

    // MARK: - Outlets

    @IBOutlet weak var nameField: UnderlineTextField!
    @IBOutlet weak var emailField: UnderlineTextField!
    @IBOutlet weak var passwordField: UnderlineTextField!
    @IBOutlet weak var confirmPasswordField: UnderlineTextField!
    @IBOutlet weak var registerButton: RoundRectButton!

    override func viewDidLoad() {
        registerButton.isEnabled = false
        nameField.tag = 0
        emailField.tag = 1
        passwordField.tag = 2
        confirmPasswordField.tag = 3

        nameField.delegate = self
        emailField.delegate = self
        passwordField.delegate = self
        confirmPasswordField.delegate = self
    }

    @IBAction func textFieldDidChange(_ sender: Any) {
        updateValidForm()
    }

    @IBAction func registerPressed(_ sender: Any) {
        register()
    }

    // MARK: - Private

    private func updateValidForm() {
        guard
            let name = nameField.text,
            let email = emailField.text,
            let pass = passwordField.text,
            let confirmPass = confirmPasswordField.text
        else {
            registerButton.isEnabled = false
            return
        }

        if
            !name.isEmpty &&
            email.isValidEmail &&
            pass.count > 6 &&
            confirmPass == pass {
            registerButton.isEnabled = true
        } else {
            registerButton.isEnabled = false
        }
    }

    private func register() {
        guard
            let email = emailField.text,
            let pass = passwordField.text
        else {
            return
        }

        Auth.auth().createUser(withEmail: email, password: pass) { [weak self] (result, error) in
            guard
                let user = result?.user,
                error == nil
            else {
                self?.handleError(error)
                return
            }

            if let authStore = try? Container.resolve(AuthenticationStore.self) {
                authStore.store(user: user, with: pass)
                if let database = try? Container.resolve(DatabaseManager.self) {
                    var userModel = UserFlyweight(id: user.uid)
                    userModel.entitlement = Entitlement.student
                    userModel.name = self?.nameField.text
                    database.updateUser(userModel)
                    authStore.currentUser = userModel
                    self?.performSegue(withIdentifier: Identifiers.Segue.toMain.rawValue, sender: self)
                }
            }
        }
    }

    private func handleError(_ error: Error?) {
        guard let error = error else {
            print("Error is nil, but user not returned. Check firebase!")
            return
        }
        let alert = UIAlertController(title: "Error", message: "An error occured: \(error.localizedDescription)", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}

extension RegisterViewController: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField.tag {
        case 0:
            emailField.becomeFirstResponder()
        case 1:
            passwordField.becomeFirstResponder()
        case 2:
            confirmPasswordField.becomeFirstResponder()
        default:
            view.endEditing(true)
        }

        return false
    }
}
