//
//  PendingUserTableViewCell.swift
//  Smart Training Log
//

import UIKit

protocol PendingUserTableViewCellDelegate: class {
    func didAccept(user: inout UserFlyweight)
    func didDecline(user: UserFlyweight)
}

class PendingUserTableViewCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!

    weak var delegate: PendingUserTableViewCellDelegate?
    private var user: UserFlyweight?

    func configure(with user: UserFlyweight) {
        nameLabel.text = user.name
        self.user = user
    }

    @IBAction func acceptPressed(_ sender: Any) {
        if var user = self.user {
            delegate?.didAccept(user: &user)
        }
    }

    @IBAction func declinePressed(_ sender: Any) {
        if let user = self.user {
            delegate?.didDecline(user: user)
        }    }
}
