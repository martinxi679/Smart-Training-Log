//
//  TreatmentDetailsViewController.swift
//  Smart Training Log
//

import UIKit

class TreatmentDetailsViewController: UIViewController {

    var treatment: TreatmentModel?

    @IBOutlet weak var addCommentButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let addCommentVC = segue.destination as? AddCommentViewController {
            addCommentVC.treatment = treatment
        } else if let detailVC = segue.destination as? TreatmentDetailViewController {
            detailVC.treatment = treatment
        }
    }
}
