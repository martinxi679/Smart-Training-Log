//
//  StartupManager.swift
//  Smart Training Log
//

import Foundation
import Firebase
import CoreData

class StartupManager {
    
    // MARK: - Public
    
    func setup() {
    
        setupHoratio()
        setupFirebase()
        configureNavBar()
        pruneCoreData()
    }
    
    
    // MARK: - Private
    
    private func setupHoratio() {
        
        // Register the main operation queue for horatio
        Container.register(OperationQueue.self) { _ in OperationQueue() }
        
        // Register the persistence manager for the core data stack
        Container.register(PersistenceManager.self) { _ in PersistenceManager() }

        // Register the authentication store
        Container.register(AuthenticationStore.self) {_ in AuthenticationStore() }

        // Register the shared url session
        Container.register(URLSession.self) { _ in URLSession.shared }

        // Register the cache manager
        Container.register(DownloadCacheManager.self) { _ in DownloadCacheManager() }


        Container.register(CloudStorageManager.self) { _ in CloudStorageManager() }
        Container.register(DatabaseManager.self) { _ in DatabaseManager() }
    }
    
    private func setupFirebase() {
        FirebaseApp.configure()
    }

    private func pruneCoreData() {
        guard let persistantStore = try? Container.resolve(PersistenceManager.self) else { return }

        let treatmentRequest: NSFetchRequest<Treatment> = Treatment.fetchRequest()
        let deleteTreatmentsRequest = NSBatchDeleteRequest(fetchRequest: treatmentRequest as! NSFetchRequest<NSFetchRequestResult>)

        let userRequest: NSFetchRequest<UserInfo> = UserInfo.fetchRequest()
        let deleteUserRequest = NSBatchDeleteRequest(fetchRequest: userRequest  as! NSFetchRequest<NSFetchRequestResult>)


        persistantStore.persistentContainer.performBackgroundTask { (context) in
            do {
                try context.execute(deleteTreatmentsRequest)
                try context.execute(deleteUserRequest)
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    private func configureNavBar() {

        let navBarAppearence = UINavigationBar.appearance()
        
        navBarAppearence.barTintColor = Palette.navBarBlue
        navBarAppearence.tintColor = UIColor.white
        navBarAppearence.isTranslucent = false
        navBarAppearence.titleTextAttributes = [NSAttributedStringKey.foregroundColor: Palette.pureWhite]

        let tabBarAppearence = UITabBar.appearance()

        tabBarAppearence.barTintColor = Palette.navBarBlue
        tabBarAppearence.tintColor = Palette.pureWhite
        tabBarAppearence.isTranslucent = false
        tabBarAppearence.items?.forEach({$0.setBadgeTextAttributes([NSAttributedStringKey.foregroundColor.rawValue: Palette.pureWhite], for: .normal)})
    }
    
}
