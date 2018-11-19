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
    @IBOutlet weak var addTeamButton: UIButton!

    var viewModel =  ProfileViewModel()
    var disposeBag: Disposal = []

    override func viewDidLoad() {
        tabBarItem.title = "Profile"

        // Setup
        viewModel.name.observe { [weak self] (name, _) in
            self?.nameLabel.text = name
        }.add(to: &disposeBag)

        viewModel.image.observe{ [weak self] (image, _) in
            self?.profileImageView.image = image ?? UIImage(named: "defaultProfile")
        }.add(to: &disposeBag)

        if viewModel.user?.isAthlete ?? true {

            viewModel.sport.observe { [weak self] (sport, _) in
                self?.sportLabel.text = sport ?? "Sport"
            }.add(to: &disposeBag)

            addTeamButton.isHidden = true
            tableView.isHidden = true
        } else {
            sportLabel.text = "Manage My Teams"
            tableView.dataSource = self
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.update()
        tableView.reloadData()
    }
}

extension ProfileViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let user = viewModel.user as? UserFlyweight else {
            return 0
        }
        return user.teams.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let user = viewModel.user as? UserFlyweight else { return UITableViewCell() }

        let cell = tableView.dequeueReusableCell(withIdentifier: "teamNameCell", for: indexPath)
        cell.textLabel?.text = user.teams[indexPath.row]

        return cell
    }
}
