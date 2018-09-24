//
//  ProfileViewController.swift
//  Smart Training Log
//

import UIKit
import Observable

class ProfileViewController: UIViewController, ImageDownloadable {

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

        viewModel.image.observe{ [weak self] (image, _) in
            self?.profileImageView.image = image
        }.add(to: &disposeBag)

        viewModel.sport.observe({ [weak self] (sport, _) in
            self?.sportLabel.text = sport ?? "Sport"
        }).add(to: &disposeBag)

        tabBarItem.title = "Profile"
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.update()
    }

}
