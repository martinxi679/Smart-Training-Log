//
//  ProfileViewModel.swift
//  Smart Training Log
//

import UIKit
import Observable


class ProfileViewModel {

    var name: Observable<String?> = Observable(nil)
    var image: Observable<URL?> = Observable(nil)
    var sport: Observable<String?> = Observable(nil)

    init() {
        guard let authStore = try? Container.resolve(AuthenticationStore.self) else { return }
        if let user = authStore.user {
            name.value = user.displayName
            image.value = user.photoURL
            // sport = user.sport
        }
    }
}
