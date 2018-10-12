//
//  TreatmentsViewController.swift
//  Smart Training Log
//

import UIKit
import Firebase
import FirebaseDatabase
import Observable

class TreatmentsViewController: UIViewController {

    var viewModel = AllTreatmentsViewModel()
    var disposeBag: Disposal = []

    let treatmentInfoCellID = "AllTreatmentsTableViewCell"

    @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        tableView.register(UINib(nibName: treatmentInfoCellID, bundle: nil), forCellReuseIdentifier: treatmentInfoCellID)
        tableView.dataSource = self
        tableView.delegate = self
        viewModel.refreshed.observe({ [weak self] (refreshed, _) in
            if refreshed {
                self?.tableView.reloadData()
            }
        }).add(to: &disposeBag)
    }
}

extension TreatmentsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let treatment = viewModel.treatment(for: indexPath) else { return }
        // TODO: Nav to treatment detail page
    }
}

extension TreatmentsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfRows(in: section)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: treatmentInfoCellID, for: indexPath) as? AllTreatmentsTableViewCell else {
            assertionFailure()
            return UITableViewCell()
        }

        guard let treatment = viewModel.treatment(for: indexPath),
            let athlete = viewModel.athlete(id: treatment.athleteID) else {
            return cell
        }
        cell.configure(with: treatment, athlete: athlete)
        return cell
    }
}
