//
//  AddTreatmentViewController.swift
//  Smart Training Log
//
//  Created by Alice Lew on 9/30/18.
//  Copyright © 2018 CS4261. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import FirebaseDatabase

class AddTreatmentViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate {
    
    var ref: DatabaseReference!
    
    @IBOutlet weak var treatmentTitle: UITextField!
    @IBOutlet weak var studentName: UITextField!
    @IBOutlet weak var treatmentContent: UITextView!
    @IBOutlet weak var addButton: UIButton!
    
    override func viewDidLoad() {
        treatmentTitle.tag = 0
        studentName.tag = 1
        treatmentContent.tag = 2
        
        treatmentTitle.delegate = self
        studentName.delegate = self
        treatmentContent.delegate = self
        addButton.isEnabled = true
        ref = Database.database().reference().child("treatments");
    }
    
    @IBAction func addButtonPressed(_ sender: Any) {
        addTreatment()
    }
    
    private func addTreatment() {
        guard
            let title = treatmentTitle.text,
            let name = studentName.text,
            let content = treatmentContent.text
        else {
            return
        }
        
        if
            let authStore = try? Container.resolve(AuthenticationStore.self),
            let storageManager = try? Container.resolve(CloudStorageManager.self),
            let user = authStore.user {
            
            let treatment = ["uid": user.uid,
                                "title": title as String,
                                "name": name as String,
                                "content": content as String]
            let key = user.uid
            //let ref = Database.database().reference().child("treatments");
            ref.child(key).setValue(treatment)
            
//            //Save treatment
//            if let dataManager = try? Container.resolve(DatabaseManager.self) {
//                let key = "treatments"
//                let ref = Database.database().reference().child("treatments");
//                ref.child(key).setValue(treatment)
//                dataManager.updateTreatment(user: user, treatment: treatment)
//            }
            
            // Change profile
            let request = user.createProfileChangeRequest()
            request.displayName = name
            request.photoURL = storageManager.getProfileImageURL(user: user)
            request.commitChanges(completion: nil)
            
            self.navigationController?.popViewController(animated: true)
        }
        
    }
    
    
}
