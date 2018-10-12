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

    var user: UserModel?

    private var disposeBag: Disposal = []
    private var resultsController: NSFetchedResultsController<UserInfo>?

    override init() {
        super.init()

        guard let user = (try? Container.resolve(AuthenticationStore.self))?.firebaseUser else { return }
        self.user = UserFlyweight(uid: user.uid)
        guard let persistenceManager = try? Container.resolve(PersistenceManager.self) else { return }
        let request = UserInfo.fetchRequest(uid: user.uid)
        request.sortDescriptors = [NSSortDescriptor(key: "uid", ascending: true)]
        resultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: persistenceManager.persistentContainer.viewContext, sectionNameKeyPath: nil, cacheName: nil)

        resultsController?.delegate = self
        try? resultsController?.performFetch()
        update()
    }

    func update() {
        if let user = resultsController?.fetchedObjects?.first {
            self.user?.update(with: user)
            name.value = user.name
            sport.value = user.sport
            if let urlStr = user.photoURL {
                getProfileImage(URL(string: urlStr))
            }
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

extension ProfileViewModel: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        update()
    }
}
