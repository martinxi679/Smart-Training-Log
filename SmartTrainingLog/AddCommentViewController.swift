//
//  AddCommentViewController.swift
//  Smart Training Log
//

import UIKit

class AddCommentViewController: UIViewController {

    @IBOutlet weak var commentContent: UITextView!
    @IBOutlet weak var addButton: UIButton!
    
    var treatment: TreatmentModel?

    weak var delegate: TreatmentUpdatableDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        commentContent.text = ""
    }
    

    @IBAction func addCommentPressed(_ sender: Any) {
        addComment()
    }

    @IBAction func cancelPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }

    private func addComment() {
        guard
            let currentTreatment = treatment as? TreatmentFlywieght,
            let trainerID = (try? Container.resolve(AuthenticationStore.self))?.currentUser?.id
            else {
                // Show user alert!
                return
        }
        
        var newComment = CommentFlyweight()
        newComment.trainerID = trainerID
        newComment.content = commentContent.text
        newComment.date = Date()
        
        guard let dbManager = try? Container.resolve(DatabaseManager.self) else { return }
        dbManager.addComment(comment: newComment, toTreatment: currentTreatment)
        treatment?.comments.append(newComment)
        delegate?.didUpdateTreatment(treatment as! TreatmentFlywieght)
        self.dismiss(animated: true, completion: nil)
    }
}
