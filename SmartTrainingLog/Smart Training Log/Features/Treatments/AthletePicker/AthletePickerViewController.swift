//
//  AthletePickerViewController.swift
//  Smart Training Log
//

import UIKit
import Observable

protocol AthletePickerDataSource: class {
    func numberOfAthletes() -> Int
    func athlete(at index: IndexPath) -> UserModel
}

protocol AthletePickerDelegate: class {
    func athletePicker(didFinishSelectingWith athlete: UserModel)
    func athletePickerDidCancel()
}

let athleteViewModel = AllAthletesViewModel()

class AthletePickerViewController: UIViewController {

    weak var delegate: AthletePickerDelegate?

    @IBOutlet weak var tableView: UITableView!

    private let athleteCellID = "AthletePickerTableViewCell"

    var disposeBag: Disposal =  []

    override func viewDidLoad() {
        tableView.register(UINib(nibName: athleteCellID, bundle: nil), forCellReuseIdentifier: athleteCellID)
        tableView.delegate = self
        tableView.dataSource = self
        athleteViewModel.refreshed.observe({[weak self] (_,_) in
            self?.tableView.reloadData()
        }).add(to: &disposeBag)
    }

    @IBAction func cancelPressed(_ sender: Any) {
        delegate?.athletePickerDidCancel()
        dismiss(animated: true, completion: nil)
    }

}

extension AthletePickerViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let athlete = athleteViewModel.athlete(for: indexPath) else { return }
        delegate?.athletePicker(didFinishSelectingWith: athlete)
        dismiss(animated: true, completion: nil)
    }
}

extension AthletePickerViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return athleteViewModel.numberOfRows(in: section)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: athleteCellID, for: indexPath) as? AthletePickerTableViewCell else {
            assertionFailure()
            return UITableViewCell()
        }

        guard let athlete = athleteViewModel.athlete(for: indexPath) as? UserFlyweight else { return cell }
        cell.configure(with: athlete)
        return cell
    }
}
