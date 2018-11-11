//
//  AddTreatmentViewController.swift
//  Smart Training Log
//

import Foundation
import UIKit
import Firebase
import FirebaseDatabase

class AddTreatmentViewController: UIViewController {

    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var treatmentNameLabel: UILabel!
    @IBOutlet weak var athleteDetailView: AthleteInfoDetailView!
    @IBOutlet weak var infoTextField: UITextView!
    @IBOutlet weak var addButton: UIButton!

    enum SegueType: String {
        case namePickerSegue
    }

    var trainer: UserModel?
    var selectedAthlete: UserModel?

    override func viewDidLoad() {
        treatmentNameLabel.isHidden = true
        addButton.isEnabled = true
        infoTextField.text = ""
        athleteDetailView.isHidden = true
        datePicker.setDate(Date().addingTimeInterval(60.0 * 30.0), animated: false)
        if let user = (try? Container.resolve(AuthenticationStore.self))?.currentUser,
            user.isTrainer {
            trainer = user
        }
    }
    
    @IBAction func addButtonPressed(_ sender: Any) {
        addTreatment()
    }

    private func addTreatment() {
        guard
            let athlete = selectedAthlete
        else {
            // Show user alert!
            return
        }

        var newTreatment = TreatmentFlywieght()
        newTreatment.athleteID = athlete.name?.sha256()
        newTreatment.trainerID = trainer?.id
        newTreatment.info = infoTextField.text
        newTreatment.treatment = treatmentNameLabel.text
        newTreatment.date = datePicker.date

        guard let dbManager = try? Container.resolve(DatabaseManager.self) else { return }
        dbManager.addTreatment(treatment: &newTreatment)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard
            let id = segue.identifier,
            let segueType = SegueType(rawValue: id)
        else {
            return
        }
        switch segueType {
        case .namePickerSegue:
            if let namePickerVC = segue.destination as? AthletePickerViewController {
                namePickerVC.delegate = self
            }
        }
    }
}

extension AddTreatmentViewController: AthletePickerDelegate {
    func athletePicker(didFinishSelectingWith athlete: UserModel) {
        guard let athlete = athlete as? StudentModel else { return }
        athleteDetailView.reset()
        athleteDetailView.configure(with: athlete)
        athleteDetailView.isHidden = false
        selectedAthlete = athlete
    }

    func athletePickerDidCancel() {
        // Nothing to do right now
    }
}
