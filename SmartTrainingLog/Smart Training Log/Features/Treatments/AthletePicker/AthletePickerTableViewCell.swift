//
//  AthletePickerTableViewCell.swift
//  Smart Training Log
//

import UIKit

class AthletePickerTableViewCell: UITableViewCell {

    
    @IBOutlet weak var athleteDetailView: AthleteInfoDetailView!

    override func prepareForReuse() {
        athleteDetailView.reset()
    }

    func configure(with athlete: UserModel) {
        athleteDetailView.configure(with: athlete)
    }

}
