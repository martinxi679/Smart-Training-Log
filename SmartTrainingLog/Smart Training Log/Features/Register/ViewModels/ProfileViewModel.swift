//
//  ProfileViewModel.swift
//  Smart Training Log
//

import UIKit
import Observable
import CoreData


class ProfileViewModel: NSObject {

    var name: Observable<String?> = Observable(nil)
    var image: Observable<UIImage?> = Observable(nil)
    var sport: Observable<String?> = Observable(nil)

    var user: Observable<UserModel?> = Observable(nil)

    override init() {
        super.init()
        update()
    }

    func update() {
        guard let authManager = try? Container.resolve(AuthenticationStore.self) else { return }
        user.value = authManager.currentUser

        if let id = user.value?.id {
            (try? Container.resolve(DatabaseManager.self))?.getUser(id: id, completion: { [weak self] user in
                self?.user.value = user
                self?.name.value = user?.name
                self?.sport.value = user?.sport?.rawValue
                self?.getProfileImage()
                authManager.currentUser = user
            })
        }
        name.value = user.value?.name
        sport.value = (user.value as? StudentModel)?.sport?.rawValue ?? ""
        getProfileImage()
    }

    private func getProfileImage() {
        guard let cloudManager = try? Container.resolve(CloudStorageManager.self) else { return }
        guard let user = user.value else { return }
        guard let url = cloudManager.getProfileImageURL(user: user) else { return }

        // If we already have a cached image, use that
        if let authManager = try? Container.resolve(AuthenticationStore.self) {
            if let imageVal = authManager.cachedProfilePicture.value {
                image.value = imageVal
                return
            }
        }

        cloudManager.getProfilePicture(url: url, handler: { [weak self] (image) in
            guard let image = image else { return }
            self?.image.value = image
            (try? Container.resolve(AuthenticationStore.self))?.cachedProfilePicture.value = image
        })
    }
}
