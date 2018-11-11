//
//  DatabaseManager.swift
//  Smart Training Log
//

import Foundation
import FirebaseFirestore
import FirebaseDatabase
import FirebaseAuth
import CodableFirebase

// MARK: - Database Core Functions

class DatabaseManager {

    var rootRef = Database.database().reference()

    private var db = Firestore.firestore()

    var firestoreDecoder = FirestoreDecoder()
    var firestoreEncoder = FirestoreEncoder()

    var decoder = FirebaseDecoder()
    var encoder = FirebaseEncoder()

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

extension DatabaseManager {

    func getUser(id: String, completion: @escaping (UserFlyweight?) -> Void) {
        let ref = rootRef.child(Root.Users.name).child(id)
        ref.observeSingleEvent(of: .value) { [weak self] (snapshot) in
            guard let value = snapshot.value else { completion(nil); return }
            let user = try? self?.decoder.decode(UserFlyweight.self, from: value)
            completion(user ?? nil)
        }
    }

    func updateUser(_ user: UserFlyweight) {
        guard let uid = user.id else { return }
        let ref = rootRef.child(Root.Users.name).child(uid)
        if let encodedUser = try? encoder.encode(user) {
            ref.setValue(encodedUser)
        }
        if let authStore = try? Container.resolve(AuthenticationStore.self) {
            authStore.currentUser = user
        }
    }

    func getAthletes(team: String, trainer: UserFlyweight, completion: @escaping (([StudentModel]) -> Void)) {
        let ref = db.collection(team)
        guard trainer.teams.contains(team) else { return }

        ref.getDocuments{ [weak self] (snapshot, error) in
            guard
                error == nil,
                let snapshot = snapshot,
                !snapshot.isEmpty,
                let strongSelf = self
                else {
                    completion([])
                    return
            }
            var athletes: [StudentModel] = []
            for document in snapshot.documents {
                if var athlete = try? strongSelf.firestoreDecoder.decode(UserFlyweight.self, from: document.data()) {
                    athlete.id = athlete.name?.sha256()
                    athletes.append(athlete)
                }
            }
            completion(athletes)
        }
    }
}

// MARK: - Treatments

extension DatabaseManager {

    func addTreatment(treatment: inout TreatmentFlywieght) {
        guard let athleteID = treatment.athleteID else { return }
        if let id = rootRef.child(Root.Treatments.name).child(athleteID).childByAutoId().key {
            treatment.id = id
            updateTreatment(treatment: treatment)
        }
    }

    func updateTreatment(treatment: TreatmentFlywieght) {
        guard let id = treatment.id else { return }
        guard let athleteID = treatment.athleteID else { return }
        let ref = rootRef.child(Root.Treatments.name).child(athleteID).child(id)

        let encoder = FirebaseEncoder()
        encoder.dateEncodingStrategy = .iso8601

        if let value = try? encoder.encode(treatment) {
            ref.setValue(value)
        }
    }

    func getTreatments(forUserID: String, completionHandler: @escaping ([TreatmentModel]) -> Void) {

        var treatments: [TreatmentModel] = []

        let ref = rootRef.child(Root.Treatments.path).child(forUserID)
        ref.observeSingleEvent(of: .value) { [weak self] (snapshot, error) in
            guard error == nil, let strongSelf = self else { completionHandler([]); return }
            for child in snapshot.children {
                guard let childval = child as? DataSnapshot else { continue }
                guard let val = childval.value else { continue }

                if let treatment = try? strongSelf.decoder.decode(TreatmentFlywieght.self, from: val) {
                    treatments.append(treatment)
                }
            }
            completionHandler(treatments)
        }
    }
    
    func getPastTreatments(forUserID: String, completionHandler: @escaping ([TreatmentModel]) -> Void) {
        
        var treatments: [TreatmentModel] = []
        
        let ref = rootRef.child(Root.Treatments.path).child(forUserID)
        ref.observeSingleEvent(of: .value) { [weak self] (snapshot, error) in
            guard error == nil, let strongSelf = self else { completionHandler([]); return }
            for child in snapshot.children {
                guard let childval = child as? DataSnapshot else { continue }
                guard let val = childval.value else { continue }
                
                if let treatment = try? strongSelf.decoder.decode(TreatmentFlywieght.self, from: val) {
                    let calendar = Calendar.current
                    
                    //treatment's date and time
                    let treatmentDate = treatment.date
//                    let treatmentHour = calendar.component(.hour, from: treatmentDate!)
//                    let treatmentMinute = calendar.component(.minute, from: treatmentDate!)
                    
                    // current date and time
                    let currentDate = Date()
//                    let currentHour = calendar.component(.hour, from: currentDate)
//                    let currentMinutes = calendar.component(.minute, from: currentDate)
                    
                    if (treatmentDate! < currentDate) { // if treatmentDate is before currentDate aka its already passed
                        treatments.append(treatment)
                    }
                }
            }
        }
        completionHandler(treatments)
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
