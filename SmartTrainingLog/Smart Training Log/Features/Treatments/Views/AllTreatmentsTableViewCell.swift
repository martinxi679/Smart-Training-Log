//
//  AllTreatmentsTableViewCell.swift
//  Smart Training Log
//

import UIKit

class AllTreatmentsTableViewCell: UITableViewCell {

    @IBOutlet weak var athleteNameLabel: UILabel!
    @IBOutlet weak var treatmentLabel: UILabel!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var checkedInView: UIStackView!

    func configure(with treatment: TreatmentModel, athlete: UserModel) {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
            athleteNameLabel.text = athlete.name
        treatmentLabel.text = treatment.treatment
        infoLabel.text = treatment.info
        if let date = treatment.date {
            dateLabel.text = formatter.string(from: date)
        }

        if treatment.checkin ?? false {
            checkedInView.isHidden = false
        } else {
            checkedInView.isHidden = true
        }
    }

    override func prepareForReuse() {
        athleteNameLabel.text = nil
        treatmentLabel.text = nil
        dateLabel.text = nil
        infoLabel.text = nil
    }

}
