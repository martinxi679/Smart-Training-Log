//
//  HistoryViewController.swift
//  Smart Training Log
//

import UIKit
import Firebase
import FirebaseDatabase
import Observable

class HistoryViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var viewModel = PastTreatmentsViewModel()
    var disposeBag: Disposal = []

    var selectedTreatment: TreatmentModel?
    
    let treatmentInfoCellID = "AllTreatmentsTableViewCell"

    var refreshControl: UIRefreshControl?

    override func viewDidLoad() {
        if refreshControl == nil {
            refreshControl = UIRefreshControl()
            refreshControl?.addTarget(self, action: #selector(refresh), for: .valueChanged)

            tableView.addSubview(refreshControl!)
        }
        tableView.register(UINib(nibName: treatmentInfoCellID, bundle: nil), forCellReuseIdentifier: treatmentInfoCellID)
        viewModel.refreshed.observe({ [weak self] (refreshed, _) in
            if refreshed {
                self?.tableView.reloadData()
                self?.refreshControl?.endRefreshing()
            }
        }).add(to: &disposeBag)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.update(resetCache: true)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let detailVC = segue.destination as? TreatmentDetailsViewController {
            detailVC.treatment = selectedTreatment
        }
    }

    @objc
    func refresh() {
        viewModel.update(resetCache: true)
    }
}

extension HistoryViewController: UITableViewDataSource {
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

extension HistoryViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let treatment = viewModel.treatment(atIndexPath: indexPath) {
            selectedTreatment = treatment
            performSegue(withIdentifier: "ToTreatmentDetail", sender: self)
        }
        tableView.deselectRow(at: indexPath, animated: false)
    }
}
