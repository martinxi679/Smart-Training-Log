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

    override func viewDidLoad() {
        tableView.register(UINib(nibName: treatmentInfoCellID, bundle: nil), forCellReuseIdentifier: treatmentInfoCellID)
        viewModel.refreshed.observe({ [weak self] (refreshed, _) in
            if refreshed {
                self?.tableView.reloadData()
            }
        }).add(to: &disposeBag)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.update()
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
        if let treatment = viewModel.treatment(atIndexPath: indexPath) {
            // go to detail view
        }
        tableView.deselectRow(at: indexPath, animated: false)
    }
}
