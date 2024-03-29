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

        setupFirebase()
        setupHoratio()
        configureNavBar()
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

        Container.register(CloudStorageManager.self) { _ in CloudStorageManager() }
        Container.register(DatabaseManager.self) { _ in DatabaseManager() }

        Container.register(APNServiceManager.self) { _ in APNServiceManager() }

        Container.register(SMLRestfulAPI.self) { _ in SMLRestfulAPI() }

        // Register shared athlete view model
        Container.register(AllAthletesViewModel.self) { _ in AllAthletesViewModel() }
    }
    
    private func setupFirebase() {
        FirebaseApp.configure()
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
