//
//  TreatmentsViewController.swift
//  Smart Training Log
//

import UIKit
import Firebase
import FirebaseDatabase
import Observable

class TreatmentsViewController: UIViewController {

    var viewModel = UpcomingTreatmentsViewModel()
    var disposeBag: Disposal = []

    let treatmentInfoCellID = "AllTreatmentsTableViewCell"

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addTreatmentItem: UIBarButtonItem!

    var refreshControl: UIRefreshControl?

    override func viewDidLoad() {
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(refresh), for: .valueChanged)

        tableView.addSubview(refreshControl!)
        tableView.register(UINib(nibName: treatmentInfoCellID, bundle: nil), forCellReuseIdentifier: treatmentInfoCellID)
        viewModel.refreshed.observe({ [weak self] (refreshed, _) in
            if refreshed {
                self?.tableView.reloadData()
                self?.refreshControl?.endRefreshing()
            }
        }).add(to: &disposeBag)

        NotificationCenter.default.addObserver(forName: Notification.Name.NewTreatmentRecieved, object: nil, queue: nil, using: { [weak self] _ in
            self?.viewModel.update(resetCache: true)
        })

        if let user = (try? Container.resolve(AuthenticationStore.self))?.currentUser {
            if !user.isTrainer {
                // Remove all buttons for trainers only
                navigationItem.rightBarButtonItems?.removeAll()
            }
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.update(resetCache: true)
    }

    func handleDeeplink(_ deeplink: Deeplink) {
        switch deeplink {
        case .viewTreatment(let tid):
            for section in 0..<viewModel.numberOfSections() {
                for row in 0..<viewModel.numberOfTreatments(in: section) {
                    let indexPath = IndexPath(row: row, section: section)
                    let treatment = viewModel.treatment(atIndexPath: indexPath)
                    if treatment?.id == tid {
                        tableView.selectRow(at: indexPath, animated: true, scrollPosition: .middle)
                    }
                }
            }
        case .editTreatment(let tid):
            for section in 0..<viewModel.numberOfSections() {
                for row in 0..<viewModel.numberOfTreatments(in: section) {
                    let indexPath = IndexPath(row: row, section: section)
                    let treatment = viewModel.treatment(atIndexPath: indexPath)
                    if treatment?.id == tid {
                        tableView.selectRow(at: indexPath, animated: true, scrollPosition: .middle)
                        self.tableView(tableView, didSelectRowAt: indexPath)
                    }
                }
            }
        default:
            return
        }
    }

    @objc
    func refresh() {
        viewModel.update(resetCache: true)
    }
}

extension TreatmentsViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.numberOfSections()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfTreatments(in: section)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: treatmentInfoCellID, for: indexPath) as? AllTreatmentsTableViewCell else { return UITableViewCell() }

        guard
            let treatment = viewModel.treatment(atIndexPath: indexPath),
            let athleteID = treatment.athleteID,
            let athlete = viewModel.athleteForID(id: athleteID)
        else {
            return cell
        }

        cell.configure(with: treatment, athlete: athlete)
        return cell
    }
}

extension TreatmentsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let treatment = viewModel.treatment(atIndexPath: indexPath),
            let athleteID = treatment.athleteID,
            let athlete = viewModel.athleteForID(id: athleteID ) {
            // go to detail view

            guard let currentUser = (try? Container.resolve(AuthenticationStore.self))?.currentUser,
                !currentUser.isAthlete
            else {
                return
            }
            let storyboard = UIStoryboard(name: "Treatments", bundle: nil)
            if let updateVC = storyboard.instantiateViewController(withIdentifier: "AddTreatmentViewController") as? AddTreatmentViewController {
                updateVC.treatment = treatment as? TreatmentFlywieght
                updateVC.selectedAthlete = athlete
                updateVC.treatmentVCType = .update
                navigationController?.pushViewController(updateVC, animated: true)
            }
        }
        tableView.deselectRow(at: indexPath, animated: false)
    }
}
