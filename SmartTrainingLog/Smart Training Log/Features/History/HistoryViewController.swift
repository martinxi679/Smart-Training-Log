//
//  HistoryViewController.swift
//  Smart Training Log
//
//  Created by Alice Lew on 11/11/18.
//  Copyright © 2018 CS4261. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import Observable

class HistoryViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var viewModel = AllTreatmentsViewModel()
    var disposeBag: Disposal = []
    
    let treatmentInfoCellID = "AllTreatmentsTableViewCell"

    override func viewDidLoad() {
        tableView.register(UINib(nibName: treatmentInfoCellID, bundle: nil), forCellReuseIdentifier: treatmentInfoCellID)
        viewModel.refreshed.observe({ [weak self] (refreshed, _) in
            if refreshed {
                self?.tableView.reloadData()
            }
        }).add(to: &disposeBag)
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
