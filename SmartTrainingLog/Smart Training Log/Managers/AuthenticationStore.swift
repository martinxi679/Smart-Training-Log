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

    var currentUser: UserModel?

    var cachedProfilePicture: Observable<UIImage?> = Observable(nil)

    init() {
        NotificationCenter.default.addObserver(self, selector: #selector(updateUser), name: .MessagingTokenDidChange, object: nil)
    }

    public func store(user: User?, with password: String?) {
        let keychain = KeychainSwift()
        guard let email = user?.email, let pass = password else { return }
        keychain.set(email, forKey: AuthenticationStore.USER_EMAIL_KEY)
        keychain.set(pass, forKey: AuthenticationStore.USER_PASSWORD_KEY)
    }

    @objc
    private func updateUser() {
        guard var user = currentUser as? UserFlyweight else { return }
        if let token = (try? Container.resolve(APNServiceManager.self))?.messagingToken {
            user.deviceToken = token
        }

        if let dbManager = try? Container.resolve(DatabaseManager.self) {
            dbManager.updateUser(user)
        }
    }
}
