//
//  LoginViewController.swift
//  Smart Training Log
//  Authentication through firebaseAuth

import UIKit
import FirebaseAuth
import KeychainSwift

class LoginViewController: UIViewController {

    struct Identifiers {
        enum Segue: String {
            case toMain = "loginToMain"
        }
    }

    // MARK: - Outlets
    
    @IBOutlet weak var emailField: UnderlineTextField!
    @IBOutlet weak var passwordField: UnderlineTextField!
    @IBOutlet weak var loginButton: RoundRectButton!
        
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        loginButton.isEnabled = false

        emailField.tag = 0
        passwordField.tag = 1

        emailField.delegate = self
        passwordField.delegate = self
        
        // Fill in from keychain
        let keychain = KeychainSwift()

        if let email = keychain.get(AuthenticationStore.USER_EMAIL_KEY),
            let password = keychain.get(AuthenticationStore.USER_PASSWORD_KEY) {
            emailField.text = email
            passwordField.text = password
            updateValidFields()
            login()
        }

    }
    
    // MARK: - Actions
    
    @IBAction func loginPressed(_ sender: Any) {
        login()
    }
    
    @IBAction func textFieldDidChange(_ sender: Any) {
        updateValidFields()
    }
    
    
    // MARK: - Private
    
    private func login() {
        
        guard
            let email = emailField.text,
            let password = passwordField.text
            else {
                return
                // TODO- Error statement
        }
        
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] (result, error) in
            guard
                let user = result?.user,
                error == nil
            else {
                self?.handleError(error)
                return
            }

            if let authStore = try? Container.resolve(AuthenticationStore.self) {
                authStore.store(user: user, with: password)
                if let databaseManager = try? Container.resolve(DatabaseManager.self) {
                    databaseManager.getUser(id: user.uid, completion: { [weak self] (userFlyweight) in
                        authStore.currentUser = userFlyweight
                        (try? Container.resolve(APNServiceManager.self))?.getUpdatedMessagingToken(completion: {_ in })
                        self?.performSegue(withIdentifier: Identifiers.Segue.toMain.rawValue, sender: self)
                    })
                }
            }
        }
    }
    
    private func updateValidFields() {
        if
            let email = emailField.text,
            let password = passwordField.text,
            email.isValidEmail && password.count >= 6 {
            loginButton.isEnabled = true
        } else {
            loginButton.isEnabled = false
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

extension LoginViewController: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {

        switch textField.tag {
        case 0:
            passwordField.becomeFirstResponder()
        default:
            view.endEditing(true)
        }

        return false
    }
}
