//
//  DatabaseManager.swift
//  Smart Training Log
//

import Foundation
import FirebaseDatabase
import FirebaseAuth

class DatabaseManager {

    var rootRef = Database.database().reference()
    
    func updateUserEntitlements(user: User, entitlement: Entitlement) {
        let uid = user.uid
        let ref = rootRef.child(Root.Users.name).child(uid).child(Root.Users.Entitlement.name)
        ref.setValue(entitlement.rawValue)
        guard let authStore = try? Container.resolve(AuthenticationStore.self) else { return }
        authStore.userEntitlement.value = entitlement
    }

    func updateUserSport(user: User, sport: Sport) {
        let uid = user.uid
        let ref = rootRef.child(Root.Users.name).child(uid).child(Root.Users.Sport.name)
        ref.setValue(sport.rawValue)
        guard let authStore = try? Container.resolve(AuthenticationStore.self) else { return }
        authStore.userSport.value = sport
    }
    
    func getEntitlement(for user: User, resultHandler: @escaping (Entitlement?) -> Void = {(_) in }) -> Entitlement? {
        let uid = user.uid
        let ref = rootRef.child(Root.Users.name).child(uid)
        
        ref.observeSingleEvent(of: .value) { (value) in
            let authStore = try? Container.resolve(AuthenticationStore.self)
            if
                let entitlementValue = value.value as? [String: String],
                let entitlementStr = entitlementValue[Root.Users.Entitlement.name],
                let entitlement = Entitlement(rawValue: entitlementStr) {
                authStore?.userEntitlement.value = entitlement
                resultHandler(entitlement)
                
            } else {
                authStore?.userEntitlement.value = nil
                resultHandler(nil)
            }
        }
        
        guard let authStore = try? Container.resolve(AuthenticationStore.self) else {
            return nil
        }
        return authStore.userEntitlement.value
    }

    func getSport(for user: User, resultHandler: @escaping (Sport?) -> Void = {(_) in }) -> Sport? {
        let uid = user.uid
        let ref = rootRef.child(Root.Users.name).child(uid)

        ref.observeSingleEvent(of: .value) { (value) in
            let authStore = try? Container.resolve(AuthenticationStore.self)
            if
            let sportValue = value.value as? [String: String],
                let sportStr = sportValue[Root.Users.Sport.name],
                let sport = Sport(rawValue: sportStr) {
                authStore?.userSport.value = sport
                resultHandler(sport)
                
            } else {
                authStore?.userSport.value = nil
                resultHandler(nil)
            }
        }

        guard let authStore = try? Container.resolve(AuthenticationStore.self) else {
            return nil
        }
        return authStore.userSport.value
    }

}

fileprivate struct Root {
    static let name = ""

    struct Users {
        static let name = "users"

        struct Sport {
            static let name = "sport"
        }
        
        struct Entitlement {
            static let name = "entitlement"
        }
    }
}
