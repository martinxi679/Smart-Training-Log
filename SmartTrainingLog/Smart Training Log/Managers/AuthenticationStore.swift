//
//  AuthenticationStore.swift
//  Smart Training Log
//

import UIKit
import FirebaseAuth
import KeychainSwift
import Observable

class AuthenticationStore {

    static let USER_EMAIL_KEY = "USER_EMAIL"
    static let USER_PASSWORD_KEY = "USER_PASSWORD"

    var user: User? {
        get {
            return Auth.auth().currentUser
        }
    }

    var cachedProfilePicture: Observable<UIImage?> = Observable(nil)
    var userSport: Observable<Sport?> = Observable(nil)
    var userEntitlement: Observable<Entitlement?> = Observable(nil)

    public func store(user: User?, with password: String?) {
        let keychain = KeychainSwift()
        guard let email = user?.email, let pass = password else { return }
        keychain.set(email, forKey: AuthenticationStore.USER_EMAIL_KEY)
        keychain.set(pass, forKey: AuthenticationStore.USER_PASSWORD_KEY)
    }

}

extension User {
    var profilePicture: UIImage? {
        guard let authStore = try? Container.resolve(AuthenticationStore.self) else { return nil }
        return authStore.cachedProfilePicture.value
    }

    var sport: Sport? {
        guard let authStore = try? Container.resolve(AuthenticationStore.self) else { return nil }
        return authStore.userSport.value
    }
    
    var entitlement: Entitlement? {
        guard let authStore = try? Container.resolve(AuthenticationStore.self) else { return nil }
        return authStore.userEntitlement.value
    }
}
