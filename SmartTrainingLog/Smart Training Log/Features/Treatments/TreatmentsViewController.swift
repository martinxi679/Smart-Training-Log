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

        if let user = (try? Container.resolve(AuthenticationStore.self))?.currentUser {
            if !user.isTrainer {
                navigationItem.rightBarButtonItems?.removeAll()
            }
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.update(resetCache: true)
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
