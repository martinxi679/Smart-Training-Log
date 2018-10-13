//
//  DatabaseManager.swift
//  Smart Training Log
//

import Foundation
import FirebaseDatabase
import FirebaseAuth
import CodableFirebase

// MARK: - Database Core Functions

class DatabaseManager {

    var rootRef = Database.database().reference()

    /**
     Saves a value to the realtime database.
     - Parameter value: The value to save. Should be JSON encodable
     - Parameter path: The path to save this value to.

    */
    func saveValue(value: Any, at path: Path) {
        let ref = path.getDBReference()
        ref.setValue(value)
    }

    /**
     Gets a value at a specified path in the realtime database.
     - Parameter path: The path to get this value at.
     - Parameter key: The key for this value. Can be nil if the path contains the key or if you want the entire JSON object
     - Parameter handler: The handler for when the data is fetched. Can be omitted if the returned value is not needed.
    */
    func getValue(at path: Path, key: String? = nil, handler: @escaping (Any?) -> Void = {(_) in }) {
        let ref = path.getDBReference()
        ref.observeSingleEvent(of: .value) { (value) in
            if
                let key = key,
                value.hasChild(key){
                handler(value.childSnapshot(forPath: key).value)
            } else {
                handler(value.value)
            }
        }
    }

    /**
     Saves a user value, will be under users/($uid)/key.
     - Parameter value: The value to save. Should be JSON encodable
     - Parameter key: The key under which to save this value, i.e. "entitlement" or "sport"
     - Parameter user: The user who's value will be updated
    */
    func saveUserInfoValue(value: Any, key: String, user: User) {
        let uid = user.uid
        let path = Path(path: Root.Users.path, uid: uid, insertUIDAfter: Root.Users.name)
        path.components.append(key)
        saveValue(value: value, at: path)
    }

    /**
     Gets the user value indicated by the key specified. Will get the value under users/($uid)/key in the realtime database
     - Parameter key: Which user value to fetch
     - Parameter user: The user whos info to fetch.
     - Parameter handler: The handler block to execute with the returned value, if there is any
     */
    func getUserInfoValue(key: String, user: User, handler: @escaping (Any?) -> Void = {(_) in }) {
        let uid = user.uid
        let path = Path(path: Root.Users.path, uid: uid, insertUIDAfter: Root.Users.name)
        getValue(at: path, key: key, handler: handler)
    }

}

// MARK: - User Sport and Entitlements

extension DatabaseManager {
    
    func updateUserEntitlements(user: User, entitlement: Entitlement) {
        saveUserInfoValue(value: entitlement.rawValue, key: Root.Users.Entitlement.name, user: user)
        guard let authStore = try? Container.resolve(AuthenticationStore.self) else { return }
        authStore.userEntitlement.value = entitlement
    }

    func updateUserSport(user: User, sport: Sport) {
        saveUserInfoValue(value: sport.rawValue, key: Root.Users.Sport.name, user: user)
        guard let authStore = try? Container.resolve(AuthenticationStore.self) else { return }
        authStore.userSport.value = sport
    }
    
    func getEntitlement(for user: User, resultHandler: @escaping (Entitlement?) -> Void = {(_) in }) -> Entitlement? {
        getUserInfoValue(key: Root.Users.Entitlement.name, user: user) { (value) in
            let entitlementStr = value as? String
            let entitlement = Entitlement(rawValue: entitlementStr ?? "")
            resultHandler(entitlement)
            if let auth = try? Container.resolve(AuthenticationStore.self) {
                auth.userEntitlement.value = entitlement
            }
        }
        
        guard let authStore = try? Container.resolve(AuthenticationStore.self) else {
            return nil
        }
        return authStore.userEntitlement.value
    }

    func getSport(for user: User, resultHandler: @escaping (Sport?) -> Void = {(_) in }) -> Sport? {
        getUserInfoValue(key: Root.Users.Sport.name, user: user) { (value) in
            let sportStr = value as? String
            let sport = Sport(rawValue: sportStr ?? "")
            resultHandler(sport)
            if let auth = try? Container.resolve(AuthenticationStore.self) {
                auth.userSport.value = sport
            }
        }

        guard let authStore = try? Container.resolve(AuthenticationStore.self) else {
            return nil
        }
        return authStore.userSport.value
    }

}

extension DatabaseManager {

    func updateUser(user: UserFlyweight) {
        guard let id = user.uid else { return }
        let path = Path(path: Root.Users.path, uid: id, insertUIDAfter: Root.Users.name)
        let encoder = FirebaseEncoder()

        if let value = try? encoder.encode(user) {
            saveValue(value: value, at: path)
        }

        guard let persistenceManager = try? Container.resolve(PersistenceManager.self) else { return }
        persistenceManager.persistentContainer.performBackgroundTask { context in
            var userInfo = UserInfo.fetchOrCreate(uid: id)
            userInfo.update(with: user)
            do {
                try context.save()
            } catch {
                print(error.localizedDescription)
            }
        }
    }

    func getUser(uid: String, onCompletion: @escaping () -> Void = {}) {
        let path = Path(path: Root.Users.path, uid: uid, insertUIDAfter: Root.Users.name)

        let decoder = FirebaseDecoder()
        getValue(at: path, key: nil, handler: {(value) in
            guard let persistenceManager = try? Container.resolve(PersistenceManager.self) else { return }
            guard let value = value else { return }
            guard let user = try? decoder.decode(UserFlyweight.self, from: value) else { return }
            guard let id = user.uid else { return }
            persistenceManager.persistentContainer.performBackgroundTask({ (context) in
                var userInfo = UserInfo.fetchOrCreate(uid: id)
                userInfo.update(with: user)
                if let athletes = user.athletes {
                    for athlete in athletes {
                        guard
                            let athlete = athlete as? UserFlyweight,
                            let aID = athlete.uid
                        else {
                            continue
                        }
                        var athleteModel = UserInfo.fetchOrCreate(uid: aID)
                        athleteModel.update(with: athlete)
                        userInfo.addToAthletes(athleteModel)
                    }
                }
                do {
                    try context.save()
                } catch {
                    print(error.localizedDescription)
                }
                DispatchQueue.main.async {
                    onCompletion()
                }
            })
            self.getAthletes(for: user)
        })

    }

    func getAthletes(for user: UserModel) {

        if user.isTrainer {
            for athlete in user.getAthletes() {
                if let athleteID = athlete.uid {
                    getUser(uid: athleteID)
                }
            }
        }
    }

}

// MARK: - Treatments

extension DatabaseManager {

    func addTreatment(treatment: inout TreatmentFlywieght) {
        if let id = rootRef.child(Root.Treatments.name).childByAutoId().key {
            treatment.id = id
            updateTreatment(treatment: treatment)
        }
    }

    func updateTreatment(treatment: TreatmentFlywieght) {
        guard let id = treatment.id else { return }
        let path = Path(path: Root.Treatments.path, uid: id, insertUIDAfter: Root.Treatments.name)
        let encoder = FirebaseEncoder()
        encoder.dateEncodingStrategy = .iso8601

        if let value = try? encoder.encode(treatment) {
            saveValue(value: value, at: path)
        }

        guard let persistenceManager = try? Container.resolve(PersistenceManager.self) else { return }
        persistenceManager.persistentContainer.performBackgroundTask({ (context) in
            var model = Treatment.fetchOrCreate(id: id)
            model.update(with: treatment)
            do {
                try context.save()
            } catch {
                print(error.localizedDescription)
            }
        })
    }

    func getTreatment(_ id: String? = nil, completionHandler: @escaping () -> Void) {
        let path = Path(path: Root.Treatments.path, uid: id, insertUIDAfter: Root.Treatments.name)

        getValue(at: path, key: nil) {[weak self] (value) in
            guard let value = value else { return }

            if let treatmentValues = value as? [String: Any] {
                for id in treatmentValues.keys {
                    self?.saveTreatment(id, treatmentValues[id])
                }
            } else {
                self?.saveTreatment(id, value)
            }
            DispatchQueue.main.async {
                completionHandler()
            }
        }
    }

    private func saveTreatment(_ id: String?, _ value: Any?) {
        guard let persistenceManager = try? Container.resolve(PersistenceManager.self) else { return }
        let decoder = FirebaseDecoder()
        decoder.dateDecodingStrategy = .iso8601

        guard let authStore = try? Container.resolve(AuthenticationStore.self) else { return }
        guard let user = authStore.user else { return }

        guard let value = value else { return }

        persistenceManager.persistentContainer.performBackgroundTask { (context) in
            if let treatmentVal = try? decoder.decode(TreatmentFlywieght.self, from: value) {
                guard let tid = treatmentVal.id else { return }
                if treatmentVal.athleteID == user.uid || treatmentVal.trainerID == user.uid {
                    var model = Treatment.fetchOrCreate(id: tid)
                    model.update(with: treatmentVal)
                    do {
                        try context.save()
                    } catch {
                        print(error.localizedDescription)
                    }
                }
            }
        }
    }
}

// MARK: - Path

class Path {
    var components: [String] = []

    /**
     Creates a new path given a '/' separated string. For example, creating a path for
     foo->example->key, use "foo/example/key". If the uid is in the path, for example with
     users->(uid)->sport, provide the uid and the path string it should be inserted after. You
     can optionally include it in the origional path string as well. For example, users/uid/sport
     or users/sport with uid provided and uidAfter = users would give the same result. If the uid
     was in the path and provided by setting uid, it will not be inserted again.
     - Parameter path: The path string
     - Parameter uid: If the uid is needed in the path, it will be inserted using this value
     - Parameter uidAfter: If the uid is needed in the path, it will be inserted after this value

     */
    init(path: String, uid: String? = nil, insertUIDAfter uidAfter: String? = nil) {
        components = path.split(separator: "/").map({String($0)})
        if
            let uid = uid,
            let uidParent = uidAfter,
            let index = components.firstIndex(of: uidParent),
            components.firstIndex(of: uid) == nil {
            components.insert(uid, at: index + 1)
        }
    }

    func getDBReference() -> DatabaseReference {
        var ref = Database.database().reference()
        for child in components {
            ref = ref.child(child)
        }
        return ref
    }
}

// MARK: - Constants

fileprivate struct Root {
    static let name = ""
    static let path = ""

    struct Users {
        static let name = "users"
        static let path = Root.path + "/" + Users.name

        struct Sport {
            static let name = "sport"
            static let path = Users.path + "/" + Sport.name
        }
        
        struct Entitlement {
            static let name = "entitlement"
            static let path = Users.path + "/" + Entitlement.name
        }

        struct UserTreatments {
            static let name = "treatments"
            static let path = Users.path + "/" + UserTreatments.name
        }
    }

    struct Treatments {
        static let name = "treatments"
        static let path = Root.path + "/" + Treatments.name
    }
}
