//
//  AuthenticationStore.swift
//  Smart Training Log
//

import Foundation
import FirebaseAuth
import KeychainSwift

class AuthenticationStore {

    static let USER_EMAIL_KEY = "USER_EMAIL"
    static let USER_PASSWORD_KEY = "USER_PASSWORD"

    var user: User? {
        get {
            return Auth.auth().currentUser
        }
    }

    public func store(user: User?, with password: String?) {
        // TODO- Update keychain?
        let keychain = KeychainSwift()
        guard let email = user?.email, let pass = password else { return }
        keychain.set(email, forKey: AuthenticationStore.USER_EMAIL_KEY)
        keychain.set(pass, forKey: AuthenticationStore.USER_PASSWORD_KEY)
    }

}
