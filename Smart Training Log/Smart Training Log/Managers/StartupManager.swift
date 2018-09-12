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
    }
    
    private func setupFirebase() {
        FirebaseApp.configure()
    }
    
    private func configureNavBar() {
        
        let navBarAppearence = UINavigationBar.appearance()
        
        navBarAppearence.backgroundColor = Palette.navBarBlue
        navBarAppearence.tintColor = Palette.pureWhite
        navBarAppearence.barTintColor = Palette.navBarBlue
        navBarAppearence.titleTextAttributes = [NSAttributedStringKey.foregroundColor: Palette.pureWhite]
    }
    
}
