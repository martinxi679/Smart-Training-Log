//
//  TeamDetailsViewController.swift
//  Smart Training Log
//

import UIKit
import Observable

class TeamDetailsViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!

    var refreshControl: UIRefreshControl?

    var viewModel: TeamDetailsViewModel?

    var selectedAthlete: UserFlyweight? {
        didSet {
            playerProfileVC?.athlete = selectedAthlete
        }
    }

    weak var playerProfileVC: ViewPlayerProfileViewController?

    var teamID: String? {
        didSet {
            if let id = teamID {
                viewModel = TeamDetailsViewModel(id)
            }
        }
    }

    var disposeBag: Disposal = []

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = teamID

        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(refresh), for: .valueChanged)

        tableView.addSubview(refreshControl!)
        viewModel?.updated.observe { [weak self] (_, _) in
            self?.tableView.reloadData()
            self?.refreshControl?.endRefreshing()
        }.add(to: &disposeBag)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refresh()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toUserDetail" {
            if let detailVC = segue.destination as? ViewPlayerProfileViewController {
                playerProfileVC = detailVC
                playerProfileVC?.athlete = selectedAthlete
            }
        }
    }

    @objc
    func refresh() {
        viewModel?.update()
    }
}

extension TeamDetailsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel?.athletes.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard
            let user = viewModel?.athletes[indexPath.row],
            let name = user.name
        else {
            return UITableViewCell()
        }

        let cell = tableView.dequeueReusableCell(withIdentifier: "athleteCell", for: indexPath)

        cell.textLabel?.text = "\(name) (\(user.sport?.rawValue ?? "Unspecified"))"

        return cell
    }
}

extension TeamDetailsViewController: UITableViewDelegate {
    // TODO - work on athlete detail view for trainers
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let user = viewModel?.athletes[indexPath.row] as? UserFlyweight {
            selectedAthlete = user
        }

        tableView.deselectRow(at: indexPath, animated: true)
    }
}
