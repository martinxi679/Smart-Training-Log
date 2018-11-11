//
//  AthletePickerTableViewCell.swift
//  Smart Training Log
//

import UIKit

class AthletePickerTableViewCell: UITableViewCell {

    
    @IBOutlet var athleteDetailView: AthleteInfoDetailView!

    override func prepareForReuse() {
        super.prepareForReuse()
        athleteDetailView.reset()
    }

    func configure(with athlete: StudentModel) {
        athleteDetailView.layoutIfNeeded()
        athleteDetailView.reset()
        athleteDetailView.configure(with: athlete)
    }

}
