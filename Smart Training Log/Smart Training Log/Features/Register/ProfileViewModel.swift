//
//  ProfileViewModel.swift
//  Smart Training Log
//

import UIKit
import Observable


class ProfileViewModel {

    var name: Observable<String?> = Observable(nil)
    var image: Observable<UIImage?> = Observable(nil)
    var sport: Observable<String?> = Observable(nil)

    private var disposeBag: Disposal = []

    init() {
        guard let authStore = try? Container.resolve(AuthenticationStore.self) else { return }
        authStore.userSport.observe() { [weak self] (sport, _) in
            self?.sport.value = sport?.rawValue
        }.add(to: &disposeBag)

        authStore.cachedProfilePicture.observe(){ [weak self] (picture, _) in
            self?.image.value = picture
        }.add(to: &disposeBag)
        update()
    }

    func update() {
        guard let authStore = try? Container.resolve(AuthenticationStore.self) else { return }
        if let user = authStore.user {
            name.value = user.displayName
            self.getProfileImage(user.photoURL)
        }
    }

    private func getProfileImage(_ url: URL?) {
        guard let url = url else { return }
        guard let cloudManager = try? Container.resolve(CloudStorageManager.self) else { return }
        cloudManager.getProfilePicture(url: url, handler: { [weak self] (image) in
            guard let image = image else { return }
            self?.image.value = image
        })
    }
}
