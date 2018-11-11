//
//  AddCommentViewController.swift
//  Smart Training Log
//
//  Created by Alice Lew on 11/11/18.
//  Copyright © 2018 CS4261. All rights reserved.
//

import UIKit

class AddCommentViewController: UIViewController {

    @IBOutlet weak var commentContent: UITextView!
    @IBOutlet weak var addButton: UIButton!
    
    var trainer: UserModel?
    var selectedAthlete: UserModel?
    var viewModel = AllTreatmentsViewModel()
    
    override func viewDidLoad() {
        if let user = (try? Container.resolve(AuthenticationStore.self))?.currentUser,
            user.isTrainer {
            trainer = user
        }
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    @IBAction func addCommentPressed(_ sender: Any) {
        addComment()
    }
    
    private func addComment() {
        guard
            let athlete = selectedAthlete
            else {
                // Show user alert!
                return
        }
        
        var newComment = CommentFlyweight()
        newComment.athleteID = athlete.id
        newComment.trainerID = trainer?.id
        newComment.content = commentContent.text
        newComment.date = Date()
        
        guard let dbManager = try? Container.resolve(DatabaseManager.self) else { return }
        //dbManager.addComment(comment: &newComment)
    }

}
