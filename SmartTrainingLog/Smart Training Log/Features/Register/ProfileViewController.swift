//
//  ProfileViewController.swift
//  Smart Training Log
//

import UIKit
import Observable

class ProfileViewController: UIViewController {

    struct Identifiers {
        enum Segue: String {
            case toTeamDetail
            case toRequestTeam
            case toEditProfile
        }
    }

    // MARK: - Outlets

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var sportLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addTeamButton: UIButton!

    var refreshControl: UIRefreshControl?

    var viewModel =  ProfileViewModel()
    var disposeBag: Disposal = []

    override func viewDidLoad() {
        tabBarItem.title = "Profile"

        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(refresh), for: .valueChanged)
        tableView.addSubview(refreshControl!)

        // Setup
        viewModel.name.observe { [weak self] (name, _) in
            self?.nameLabel.text = name
        }.add(to: &disposeBag)

        viewModel.image.observe{ [weak self] (image, _) in
            self?.profileImageView.image = image ?? UIImage(named: "defaultProfile")
        }.add(to: &disposeBag)

        if viewModel.user.value?.isAthlete ?? true {

            viewModel.sport.observe { [weak self] (sport, _) in
                self?.sportLabel.text = sport ?? "Sport"
            }.add(to: &disposeBag)

            addTeamButton.isHidden = true
            tableView.isHidden = true
        } else {
            sportLabel.text = "Manage My Teams"
            tableView.dataSource = self
        }

        viewModel.user.observe({ [weak self] (_, _) in
            self?.tableView.reloadData()
            self?.refreshControl?.endRefreshing()
        }).add(to: &disposeBag)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.update()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let segueID = Identifiers.Segue(rawValue: segue.identifier ?? "") else { return}
        switch segueID {
        case .toTeamDetail:
            guard
                let user = viewModel.user.value as? UserFlyweight,
                let index = tableView.indexPathForSelectedRow?.row,
                let teamDetailVC = segue.destination as? TeamDetailsViewController
            else {
                return
            }

            teamDetailVC.teamID = user.teams[index]
        case .toEditProfile:
            return
        case .toRequestTeam:
            return
        }
    }

    @objc
    func refresh() {
        viewModel.update()
    }
}

// MARK: - UITableViewDataSource

extension ProfileViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let user = viewModel.user.value as? UserFlyweight else {
            return 0
        }
        return user.teams.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let user = viewModel.user.value as? UserFlyweight else { return UITableViewCell() }

        let cell = tableView.dequeueReusableCell(withIdentifier: "teamNameCell", for: indexPath)
        cell.textLabel?.text = user.teams[indexPath.row]

        return cell
    }
}
