//
//  TreatmentDetailViewController.swift
//  Smart Training Log
//

import UIKit
import Observable

class TreatmentDetailViewController: UIViewController {

    var treatment: TreatmentModel? {
        didSet {
            if isViewLoaded {
                update()
            }
        }
    }

    var athlete: StudentModel? {
        didSet {
            athleteLabel.text = athlete?.name
        }
    }
    var trainer: TrainerModel? {
        didSet {
            trainerLabel.text = trainer?.name
        }
    }

    var athleteViewModel = AllAthletesViewModel()

    var disposeBag: Disposal = []

    @IBOutlet weak var treatmentNameLabel: UILabel!
    @IBOutlet weak var athleteLabel: UILabel!
    @IBOutlet weak var trainerLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var completeLabel: UILabel!
    @IBOutlet weak var stackView: UIStackView!

    var commentsLabels: [UILabel] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        athleteViewModel.refreshed.observe({ [weak self] (_,_) in
            if let id = self?.treatment?.athleteID {
                guard let strongSelf = self else { return }
                strongSelf.athlete = strongSelf.athleteViewModel.athleteByID(id)
            }
        }).add(to: &disposeBag)

        update()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        update()
    }

    func update() {
        treatmentNameLabel.text = treatment?.treatment
        dateLabel.text = treatment?.date?.iso8601String
        infoLabel.text = treatment?.info
        completeLabel.text = (treatment?.complete ?? false) ? "Complete" : "Incomplete"
        if let dataManager = try? Container.resolve(DatabaseManager.self),
            let id = treatment?.trainerID {
            dataManager.getUser(id: id, completion: {[weak self] (user) in
                self?.trainerLabel.text = user?.name
            })
        }

        if let id = treatment?.athleteID {
            athlete = athleteViewModel.athleteByID(id)
        }

        for label in commentsLabels {
            label.removeFromSuperview()
        }
        commentsLabels = []

        for comment in (treatment?.comments ?? []) {
            let label = UILabel(frame: CGRect(x: 0, y: 0, width: 50, height: 20.5))
            label.text = comment.content
            label.numberOfLines = 0
            stackView.addArrangedSubview(label)
            label.trailingAnchor.constraint(equalTo: stackView.trailingAnchor).isActive = true
            label.leadingAnchor.constraint(equalTo: stackView.leadingAnchor).isActive = true
            commentsLabels.append(label)
        }

    }
}
