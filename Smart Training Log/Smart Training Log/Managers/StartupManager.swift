//
//  StartupManager.swift
//  Smart Training Log
//

import Foundation
import Firebase

class StartupManager {
    
    // MARK: - Public
    
    func setup() {
    
        setupHoratio()
        setupFirebase()
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
