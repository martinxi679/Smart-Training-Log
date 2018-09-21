//
//  ProfileViewController.swift
//  Smart Training Log
//

import UIKit
import Observable

class ProfileViewController: UIViewController {

    // MARK: - Outlets

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var sportLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!

    var viewModel =  ProfileViewModel()
    var disposeBag: Disposal = []

    override func viewDidLoad() {

        // Setup
        viewModel.name.observe { [weak self] (name, _) in
            self?.nameLabel.text = name
        }.add(to: &disposeBag)

        viewModel.image.observe{ [weak self] (url, _) in
            self?.downloadProfileImage(url)
        }.add(to: &disposeBag)
    }

    private func downloadProfileImage(_ url: URL?) {
        
    }
}
