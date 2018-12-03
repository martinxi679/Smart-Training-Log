//
//  TeamRosterViewController.swift
//  Smart Training Log
//

import UIKit

class TeamRosterViewController: UIViewController {

    var currentTeam: String? {
        didSet {
            guard isViewLoaded else { return }
            refresh()
        }
    }

    var pendingUsers: [UserFlyweight] = []
    var teamRoster: [UserFlyweight] = [] {
        didSet {
            guard isViewLoaded else { return }
            rosterTableView.reloadData()
        }
    }

    var inviteUserAlert = UIAlertController(title: "Invite User", message: "Invite a user using their email", preferredStyle: .alert)

    var selectedAthlete: UserFlyweight?

    @IBOutlet weak var inviteTableView: UITableView!
    @IBOutlet weak var rosterTableView: UITableView!

    @IBOutlet weak var inviteTableViewHeightConstraint: NSLayoutConstraint!

    let queue = DispatchQueue(label: "Admin manage team pending queue")

    struct Layout {
        static let maxInviteHeight = 250
        static let inviteCellHeight = 50
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Setup

        inviteUserAlert.addTextField(configurationHandler: { _ in })
        inviteUserAlert.addAction(UIAlertAction(title: "Invite", style: .default, handler: { [weak self] _ in
            guard let email = self?.inviteUserAlert.textFields?.first?.text else { return }
            guard let team = self?.currentTeam else { return }

            if email.isValidEmail {
                (try? Container.resolve(SMLRestfulAPI.self))?.inviteUserEmail(userEmail: email, team: team)
                self?.inviteUserAlert.textFields?.first?.text = ""
                self?.inviteUserAlert.dismiss(animated: true, completion: nil)
            }
        }))
        inviteUserAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { [weak self] _ in
            self?.inviteUserAlert.textFields?.first?.text = ""
            self?.inviteUserAlert.dismiss(animated: true, completion: nil)
        }))

        inviteTableView.register(UINib(nibName: "PendingUserTableViewCell", bundle: nil), forCellReuseIdentifier: "PendingUserTableViewCell")
        inviteTableView.rowHeight = CGFloat(Layout.inviteCellHeight)

        refresh()
    }

    @IBAction func inviteUserPressed(_ sender: Any) {
        // Todo - show modal invite form!
        present(inviteUserAlert, animated: true, completion: nil)
    }

    private func refresh() {
        guard let manager = try? Container.resolve(DatabaseManager.self) else { return }
        guard let team = currentTeam else { return }

        // Get pending
        manager.getPendingUsers(onTeam: team, completion: { [weak self] (uids) in
            guard let strongSelf = self else { return }

            for id in uids {
                manager.getUser(id: id, completion: { user in
                    if let userFlyweight = user {
                        strongSelf.queue.sync {
                            strongSelf.pendingUsers.append(userFlyweight)
                        }
                        strongSelf.configureInviteTable()
                    }
                })
            }
        })
        configureInviteTable()
    }

    private func configureInviteTable() {
        var numPending = 0
        queue.sync {
            numPending = pendingUsers.count
        }

        var inviteTableHeight = Layout.inviteCellHeight * numPending

        if inviteTableHeight > Layout.maxInviteHeight {
            inviteTableHeight = Layout.maxInviteHeight
        } else if inviteTableHeight == 0 {
            inviteTableHeight = Layout.inviteCellHeight
        }

        inviteTableViewHeightConstraint.constant = CGFloat(inviteTableHeight)
        inviteTableView.reloadData()
    }
}

extension TeamRosterViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == inviteTableView {
            var count = 0
            queue.sync {
                count = pendingUsers.count
            }
            return count > 0 ? count : 1
        } else {
            return teamRoster.count
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == inviteTableView {
            var id: String = ""
            queue.sync {
                if pendingUsers.count > 0 {
                    id = "PendingUserTableViewCell"
                } else {
                    id = "NoPendingUsersCell"
                }
            }
            let cell = inviteTableView.dequeueReusableCell(withIdentifier: id, for: indexPath)
            queue.sync {
                if pendingUsers.count > 0 {
                    (cell as! PendingUserTableViewCell).configure(with: pendingUsers[indexPath.row])
                    (cell as! PendingUserTableViewCell).delegate = self
                }
            }
            return cell
        } else {
            let cell = rosterTableView.dequeueReusableCell(withIdentifier: "rosterTableCell", for: indexPath)
            let user = teamRoster[indexPath.row]
            cell.textLabel?.text = "\(user.name ?? "") (\(user.sport?.rawValue ?? ""))"
            return cell
        }
    }
}

extension TeamRosterViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == inviteTableView {
            tableView.deselectRow(at: indexPath, animated: true)
        } else {
            selectedAthlete = teamRoster[indexPath.row]
            tableView.deselectRow(at: indexPath, animated: true)
            let storyboard = UIStoryboard(name: "Profile", bundle: nil)
            if let detailVC = storyboard.instantiateViewController(withIdentifier: "ViewPlayerProfileViewController") as? ViewPlayerProfileViewController {
                detailVC.athlete = selectedAthlete
                navigationController?.pushViewController(detailVC, animated: true)
            }
        }
    }
}

extension TeamRosterViewController: PendingUserTableViewCellDelegate {

    func didDecline(user: UserFlyweight) {
        guard let manager = try? Container.resolve(DatabaseManager.self) else { return }
        guard let team = currentTeam else { return }
        manager.removePendingUser(user, fromTeam: team)
        removePendingCell(user: user)
    }

    func didAccept(user: inout UserFlyweight) {
        guard let manager = try? Container.resolve(DatabaseManager.self) else { return }
        guard let team = currentTeam else { return }
        manager.addUser(&user, toTeam: team)
        removePendingCell(user: user)
    }

    private func removePendingCell(user: UserFlyweight) {
        var index: Int?
        queue.sync {
            index = pendingUsers.firstIndex(where: { $0.id == user.id })
            if index != nil {
                pendingUsers.remove(at: index!)
            }
        }

        inviteTableView.reloadData()
    }

}
