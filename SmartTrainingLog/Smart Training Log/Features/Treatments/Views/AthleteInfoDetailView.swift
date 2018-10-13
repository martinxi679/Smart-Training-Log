//
//  AthleteInfoDetailView.swift
//  Smart Training Log
//

import UIKit

class AthleteInfoDetailView: UIView {



    @IBOutlet var contentView: UIView!
    @IBOutlet var profileImageLoadingIndicator: UIActivityIndicatorView!

    @IBOutlet var profileImageView: UIImageView!

    @IBOutlet var nameLabel: UILabel!

    @IBOutlet var injuryLabel: UILabel!

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    private func commonInit() {
        Bundle.main.loadNibNamed("AthleteInfoDetailView", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = bounds
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
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
