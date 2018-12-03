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

// MARK: - Users

extension DatabaseManager {

    func getUser(id: String, completion: @escaping (UserFlyweight?) -> Void) {
        let ref = rootRef.child(Root.Users.name).child(id)
        ref.observeSingleEvent(of: .value) { [weak self] (snapshot) in
            guard let value = snapshot.value else { completion(nil); return }
            var user = try? self?.decoder.decode(UserFlyweight.self, from: value)
            if let current = (try? Container.resolve(AuthenticationStore.self))?.currentUser {
                if user??.id == current.id {
                    user??.authUser = current.authUser
                }
            }
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

        if user.isAthlete, let id = user.id {
            // Update firestore instance
            for team in user.teams {
                let collection = db.collection(team)
                let query = collection.whereField("id", isEqualTo: id)
                query.getDocuments(completion: { (snapshot, error) in
                    guard error == nil else { return }
                    guard let doc = snapshot?.documents.first else { return }

                    if let name = user.name,
                        let sport = user.sport?.rawValue {
                        collection.document(doc.documentID).setData(["name": name, "sport": sport, "id": id])

                    }
                })
            }
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
                if let athlete = try? strongSelf.firestoreDecoder.decode(UserFlyweight.self, from: document.data()) {
                    athletes.append(athlete)
                }
            }
            completion(athletes)
        }
    }
}

// MARK: - Teams
extension DatabaseManager {

    func createTeam(_ team: String, admin: inout UserFlyweight) {
        guard let id = admin.id else { return }
        guard let email = Auth.auth().currentUser?.email else { return }

        var ref = rootRef.child("teams").child(team).child("admin")
        ref.setValue(id)
        ref = rootRef.child("teams").child(team).child("adminEmail")
        ref.setValue(email)

        addUser(&admin, toTeam: team)
    }

    func requestTeam(user: UserFlyweight, team: String) {
        guard let id = user.id else { return }

        let ref = rootRef.child("teams").child(team).child("pending")
        ref.observeSingleEvent(of: .value, with: { [weak self] snapshot in
            guard let strongSelf = self else { return }

            guard let value = snapshot.value else {
                if let newVal = try? strongSelf.encoder.encode([id]) {
                    ref.setValue(newVal)
                }
                return
            }

            var currentPending = (try? strongSelf.decoder.decode([String].self, from: value)) ?? []

            guard !currentPending.contains(id) else {
                return
            }
            currentPending.append(id)

            if let newPending = try? strongSelf.encoder.encode(currentPending) {
                ref.setValue(newPending)
            }
        })
    }

    func getAdminStatus(_ admin: UserModel, forTeam team: String, completion: @escaping (Bool) -> Void) {
        let ref = rootRef.child("teams").child(team).child("admin")

        ref.observeSingleEvent(of: .value, with: { snapshot in
            guard let value = snapshot.value as? String else { return }
            completion(value == admin.id)
        })
    }

    func updateTeamEmail(_ newEmail: String, forTeam team: String) {
        let ref = rootRef.child("teams").child(team).child("adminEmail")
        ref.setValue(newEmail)
    }

    func getTeamEmail(_ team: String, completion: @escaping (String) -> Void) {
        let ref = rootRef.child("teams").child(team).child("adminEmail")

        ref.observeSingleEvent(of: .value, with: { snapshot in
            guard let email = snapshot.value as? String else { return }
            completion(email)
        })
    }

    func getPendingUsers(onTeam team: String, completion: @escaping ([String]) -> Void) {
        let ref = rootRef.child("teams").child(team).child("pending")
        ref.observeSingleEvent(of: .value, with: { [weak self] snapshot in
            guard let strongSelf = self else { return }

            guard let value = snapshot.value else {
                completion([])
                return
            }

            let pending = (try? strongSelf.decoder.decode([String].self, from: value)) ?? []

            completion(pending)
        })
    }

    func removePendingUser(_ user: UserFlyweight, fromTeam team: String, sendNotification: Bool = true) {
        guard let id = user.id else { return }

        let ref = rootRef.child("teams").child(team).child("pending")
        ref.observeSingleEvent(of: .value, with: { [weak self] snapshot in
            guard let strongSelf = self else { return }
            guard let value = snapshot.value else { return }

            var currentPending = (try? strongSelf.decoder.decode([String].self, from: value)) ?? []

            guard currentPending.contains(id) else {
                return
            }
            if let index = currentPending.firstIndex(where: { $0 == id }) {
                currentPending.remove(at: index)
            }

            if let newPending = try? strongSelf.encoder.encode(currentPending) {
                ref.setValue(newPending)
            }

            if sendNotification {
                // TODO- send notification to user that they were denied!
            }
        })
    }

    func addUser(_ user: inout UserFlyweight, toTeam team: String) {
        removePendingUser(user, fromTeam: team, sendNotification: false)

        user.teams.append(team)
        updateUser(user)

        let ref = db.collection(team)

        if user.isAthlete,
            let name = user.name,
            let sport = user.sport?.rawValue,
            let id = user.id {
            ref.addDocument(data: ["name": name, "sport": sport, "id": id])
        }

        //TODO- Send notification to user that they were added!
    }
}

// MARK: - Treatments
extension DatabaseManager {

    func addTreatment(treatment: inout TreatmentFlywieght, athlete: UserModel) {
        guard let athleteID = treatment.athleteID else { return }
        if let id = rootRef.child(Root.Treatments.name).child(athleteID).childByAutoId().key {
            treatment.id = id
            updateTreatment(treatment: treatment)

            guard let uid = athlete.id else { return }

            let ref = rootRef.child(Root.Treatments.name).child(athleteID).child(id)
            ref.observeSingleEvent(of: .value, with: { snapshot in
                SMLRestfulAPI.common.sendAddTreatmentNotification(userHashID: athleteID, treatmentID: id, uid: uid)
            })
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

    func getTreatment(_ id: String, athleteID: String, completion: @escaping (TreatmentModel) -> Void) {
        let ref = rootRef.child(Root.Treatments.path).child(athleteID).child(id)

        ref.observeSingleEvent(of: .value, with: { [weak self] snapshot in
            guard let strongSelf = self else { return }
            guard let val = snapshot.value else { return }

            if let treatment = try? strongSelf.decoder.decode(TreatmentFlywieght.self, from: val) {
                completion(treatment)
            }
        })
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

    func checkin(user: UserModel, treatment: inout TreatmentModel) {
        guard var flyweight = treatment as? TreatmentFlywieght else { return }
        guard let athleteID = treatment.athleteID else { return }
        guard let id = treatment.id else { return }
        guard let name = user.name else { return }

        flyweight.checkin = true
        updateTreatment(treatment: flyweight)

        // Send notification to trainer
        SMLRestfulAPI.common.sendUserCheckinNotification(userHashID: athleteID, treatmentID: id, name: name)
    }

    func addComment(comment: CommentFlyweight, toTreatment treatment: TreatmentFlywieght) {
        guard let athleteID = treatment.athleteID else { return }
        guard let treatmentID = treatment.id else { return }

        guard var comments = treatment.comments as? [CommentFlyweight] else { return }
        comments.append(comment)
        let ref = rootRef.child(Root.Treatments.path).child(athleteID).child(treatmentID).child(TreatmentFlywieght.CodingKeys.comments.rawValue)
        if let commentsValue = try? encoder.encode(comments) {
            ref.setValue(commentsValue)
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
