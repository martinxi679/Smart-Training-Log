//
//  AdminHomeViewController.swift
//  Smart Training Log
//

import UIKit

class AdminHomeViewController: UIViewController {
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    private func addSession() {
        guard
            let title = sessionTitle.text,
            let name = username.text,
            let content = sessionContent.text
        else {
            return
        }
        
        if
            let authStore = try? Container.resolve(AuthenticationStore.self),
            let storageManager = try? Container.resolve(CloudStorageManager.self),
            let user = authStore.user {
                
            let session = ["uid1": user.uid,
                            "uid2": user2.uid,
                            "title": title as String,
                            "name": name as String,
                            "content": content as String]

            let key = user.uid
            ref.child(key).setValue(session)
            }
    }
}
