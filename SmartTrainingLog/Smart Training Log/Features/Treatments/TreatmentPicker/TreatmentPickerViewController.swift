//
//  TreatmentPickerViewController.swift
//  Smart Training Log
//

import UIKit

protocol TreatmentPickerViewControllerDelegate: class {
    func finishedPickingTreatment(_ treatment: String)
}

class TreatmentPickerViewController: UIViewController {

    @IBOutlet var tableView: UITableView!

    weak var delegate: TreatmentPickerViewControllerDelegate?

    @IBAction func cancelPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}

extension TreatmentPickerViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 9
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "treatmentCell", for: indexPath)

        cell.textLabel?.text = treatmentAt(indexPath)

        return cell

    }

    private func treatmentAt(_ indexPath: IndexPath) -> String {
        switch indexPath.row {
        case 0:
            return "ACL Reconstruction"
        case 1:
            return "Arthroscopy"
        case 2:
            return "Biceps Tenodesis Surgery"
        case 3:
            return "Cartilage Restoration"
        case 4:
            return "Concussion Treatment"
        case 5:
            return "Fracture repair"
        case 6:
            return "Labral Repair"
        case 7:
            return "Platelet Rich Plasma Therapy"
        case 8:
            return "Deep Tissue"
        default:
            return ""
        }
    }
}

extension TreatmentPickerViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.finishedPickingTreatment(treatmentAt(indexPath))
        self.dismiss(animated: true, completion: nil)
    }
}




