//
//  CloudStorageManager.swift
//  Smart Training Log
//

import Foundation
import FirebaseStorage
import FirebaseAuth

class CloudStorageManager {

    private static let MAX_SIZE: Int64 = 10 * 1024 * 1024

    let rootRef: StorageReference
    let storage: Storage

    init() {
        storage = Storage.storage()
        rootRef = storage.reference()
    }

    func getResource(url: URL, handler: @escaping (Data?) -> Void) {
        var ref = rootRef
        let components = url.pathComponents
        for component in components {
            if component == "/" { continue }
            ref = ref.child(component)
        }

        ref.getData(maxSize: CloudStorageManager.MAX_SIZE, completion: { (data, error) in
            DispatchQueue.main.async {
                handler(data)
            }
        })
    }

    func getProfilePicture(url: URL, handler: @escaping (UIImage?) -> Void = {(_) in}) {

        if let authStore = try? Container.resolve(AuthenticationStore.self),
            let image = authStore.cachedProfilePicture.value {
            handler(image)
        } else {
            getResource(url: url, handler: { (data) in
                let image: UIImage?
                if let data = data {
                    image = UIImage(data: data)
                } else {
                    image = nil
                }

                handler(image)
            })
        }
    }

    func saveResource(data: Data, at url: URL) {
        var ref = rootRef
        let components = url.pathComponents
        for component in components {
            if component == "/" { continue }
            ref = ref.child(component)
        }
        ref.putData(data)
    }

    func saveProfilePicture(image: UIImage, user: UserModel){
        if
            let data = image.compressed(to: Int(CloudStorageManager.MAX_SIZE)),
            let id = user.uid,
            let url = getProfileImageURL(uid: id) {

            saveResource(data: data, at: url)
        }
    }

    func getProfileImageURL(user: UserModel) -> URL? {
        guard let uid = user.uid else { return nil }
        return URL(string: Files.Profile.Picture.url + uid + ".png") ?? nil
    }

    func getProfileImageURL(uid: String) -> URL? {
        return URL(string: Files.Profile.Picture.url + uid + ".png") ?? nil
    }
}

struct Files {
    static let url = "gs://smart-training-log-2a77d.appspot.com/"

    struct Profile {
        static let url = Files.url + "profile/"
        static let name = "profile"

        struct Picture {
            static let url = Files.Profile.url + "picture/"
            static let name = "picture"
        }
    }
}
