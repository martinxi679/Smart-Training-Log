//
//  ManageTeamsViewController.swift
//  Smart Training Log
//

import UIKit

class ManageTeamsViewController: UIViewController {

    var teams: [String: [UserFlyweight]] = [:]
    var selectedTeam: (String, [UserFlyweight])?

    weak var teamRosterVC: TeamRosterViewController?

    var createTeamAlert = UIAlertController(title: "New Team", message: "What is the team's name? Note that this will be the identifier to add other users.", preferredStyle: .alert)

    let queue = DispatchQueue(label: "Admin manage teams queue")

    @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()

        createTeamAlert.addTextField(configurationHandler: { _ in })
        createTeamAlert.addAction(UIAlertAction(title: "Create", style: .default, handler: { [weak self] _ in
            guard let newTeam = self?.createTeamAlert.textFields?.first?.text else { return }

            guard var admin = (try? Container.resolve(AuthenticationStore.self))?.currentUser as? UserFlyweight else { return }

            (try? Container.resolve(DatabaseManager.self))?.createTeam(newTeam, admin: &admin)

            self?.createTeamAlert.textFields?.first?.text = ""
            self?.refresh()
            self?.createTeamAlert.dismiss(animated: true, completion: nil)
        }))
        createTeamAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { [weak self] _ in
            self?.createTeamAlert.textFields?.first?.text = ""
            self?.createTeamAlert.dismiss(animated: true, completion: nil)
        }))

        refresh()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toManageTeam" {
            if let teamRosterVC = segue.destination as? TeamRosterViewController {
                teamRosterVC.currentTeam = selectedTeam?.0
                teamRosterVC.teamRoster = selectedTeam?.1 ?? []
                self.teamRosterVC = teamRosterVC
            }
        }
    }

    private func refresh() {
        guard let admin = (try? Container.resolve(AuthenticationStore.self))?.currentUser as? UserFlyweight else { return }

        guard let manager = try? Container.resolve(DatabaseManager.self) else { return }

        for team in admin.teams {
            manager.getAdminStatus(admin, forTeam: team, completion: { [weak self] isAdmin in
                guard isAdmin else { return }

                manager.getAthletes(team: team, trainer: admin, completion: { athletes in
                    guard let strongSelf = self else { return }
                    strongSelf.queue.sync {
                        strongSelf.teams[team] = athletes as? [UserFlyweight] ?? []
                    }
                    strongSelf.tableView.reloadData()
                })
            })
        }
    }

    @IBAction func addTeam(_ sender: Any) {
        self.present(createTeamAlert, animated: true, completion: nil)
    }
}


extension ManageTeamsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var count = 0
        queue.sync {
            count = teams.count
        }

        return count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "manageTeamsTableViewCell", for: indexPath)

        queue.sync {
            cell.textLabel?.text = teams.keys[teams.keys.index(teams.keys.startIndex, offsetBy: indexPath.row)]
        }

        return cell
    }
}

extension ManageTeamsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        queue.sync {
            let team = teams.keys[teams.keys.index(teams.keys.startIndex, offsetBy: indexPath.row)]

            if let athletes = teams[team] {
                selectedTeam = (team, athletes)
                teamRosterVC?.currentTeam = team
                teamRosterVC?.teamRoster = athletes
            }
        }
    }
}
