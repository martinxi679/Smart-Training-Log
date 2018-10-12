//
//  AthleteInfoDetailView.swift
//  Smart Training Log
//

import UIKit

class AthleteInfoDetailView: UIView {

    @IBOutlet weak var profileImageLoadingIndicator: UIActivityIndicatorView!

    @IBOutlet weak var profileImageView: UIImageView!

    @IBOutlet weak var nameLabel: UILabel!

    @IBOutlet weak var injuryLabel: UILabel!

    override func awakeFromNib() {
        profileImageLoadingIndicator.startAnimating()
    }

    func reset() {
        profileImageView.image = UIImage(named: "defaultProfile")
        profileImageLoadingIndicator.isHidden = false
        if !profileImageLoadingIndicator.isAnimating {
            profileImageLoadingIndicator.startAnimating()
        }
        nameLabel.text = "Name"
        injuryLabel.text = "Injury or description"
    }

    func configure(with athlete: UserModel) {
        nameLabel.text = athlete.name
        injuryLabel.text = athlete.injury
        athlete.getProfileImage{ [weak self] (image) in
            if image != nil {
                self?.profileImageView.image = image
            }
            self?.profileImageLoadingIndicator.stopAnimating()
            self?.profileImageLoadingIndicator.isHidden = true
        }
    }
}
