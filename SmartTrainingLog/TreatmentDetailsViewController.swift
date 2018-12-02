//
//  TreatmentDetailsViewController.swift
//  Smart Training Log
//

import UIKit

protocol TreatmentUpdatableDelegate: class {
    func didUpdateTreatment(_ treatment: TreatmentFlywieght)
}

class TreatmentDetailsViewController: UIViewController {

    var treatment: TreatmentModel?

    var detailVC: TreatmentDetailViewController?

    @IBOutlet weak var addCommentButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()

    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        detailVC?.update()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let addCommentVC = segue.destination as? AddCommentViewController {
            addCommentVC.treatment = treatment
            addCommentVC.delegate = self
        } else if let detailVC = segue.destination as? TreatmentDetailViewController {
            detailVC.treatment = treatment
            self.detailVC = detailVC
        }
    }
}

extension TreatmentDetailsViewController: TreatmentUpdatableDelegate {
    func didUpdateTreatment(_ treatment: TreatmentFlywieght) {
        self.treatment = treatment
        detailVC?.treatment = treatment
        detailVC?.update()
    }
}
