//
//  AddTreatmentViewController.swift
//  Smart Training Log
//

import Foundation
import UIKit
import Firebase
import FirebaseDatabase

class AddTreatmentViewController: UIViewController {

    enum TreatmentType {
        case add
        case update
    }

    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var treatmentNameLabel: UILabel!
    @IBOutlet weak var athleteDetailView: AthleteInfoDetailView!
    @IBOutlet weak var infoTextField: UITextView!
    @IBOutlet weak var addButton: UIButton!

    enum SegueType: String {
        case namePickerSegue
        case treatmentPickerSegue
    }

    var treatmentVCType: TreatmentType = .add {
        didSet {
            guard isViewLoaded else { return }
            switch treatmentVCType {
            case .add:
                addButton.setTitle("Add Treatment", for: UIControlState())
            case .update:
                addButton.setTitle("Save", for: UIControlState())
            }
        }
    }

    var trainer: UserModel?
    var selectedAthlete: UserModel? {
        didSet {
            if isViewLoaded {
                athleteDetailView.reset()
                if let athlete = selectedAthlete as? StudentModel {
                    athleteDetailView.configure(with: athlete)
                    athleteDetailView.isHidden = false
                } else {
                    athleteDetailView.isHidden = true
                }
            }
        }
    }
    var treatment: TreatmentFlywieght? {
        didSet {
            if treatmentVCType == .update && isViewLoaded {
                treatmentNameLabel.text = treatment?.treatment
                treatmentNameLabel.isHidden = false
                if let date = treatment?.date {
                    datePicker.setDate(date, animated: true)
                }
                addButton.setTitle("Update", for: UIControlState())
                infoTextField.text = treatment?.info
            }
        }
    }

    override func viewDidLoad() {
        treatmentNameLabel.isHidden = true
        treatmentNameLabel.text = nil
        infoTextField.layer.borderWidth = 2
        infoTextField.layer.borderColor = Palette.navBarBlue.cgColor
        addButton.isEnabled = true
        infoTextField.text = ""
        athleteDetailView.isHidden = true
        datePicker.setDate(Date().addingTimeInterval(60.0 * 30.0), animated: false)
        if let user = (try? Container.resolve(AuthenticationStore.self))?.currentUser,
            user.isTrainer {
            trainer = user
        }

        if treatmentVCType == .update {
            treatmentNameLabel.text = treatment?.treatment
            treatmentNameLabel.isHidden = false
            if let date = treatment?.date {
                datePicker.setDate(date, animated: true)
            }
            addButton.setTitle("Update", for: UIControlState())

            athleteDetailView.reset()
            if let athlete = selectedAthlete as? StudentModel {
                athleteDetailView.configure(with: athlete)
                athleteDetailView.isHidden = false
            }

            infoTextField.text = treatment?.info
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

        guard let dbManager = try? Container.resolve(DatabaseManager.self) else { return }

        switch treatmentVCType {
        case .add:
            var newTreatment = TreatmentFlywieght()
            newTreatment.athleteID = athlete.id?.sha256()
            newTreatment.trainerID = trainer?.id
            newTreatment.info = infoTextField.text
            newTreatment.treatment = treatmentNameLabel.text
            newTreatment.date = datePicker.date

            dbManager.addTreatment(treatment: &newTreatment, athlete: athlete)

        case .update:
            let athleteID = athlete.id?.sha256()
            let info = infoTextField.text
            let date = datePicker.date
            let treatmentStr = treatmentNameLabel.text

            treatment?.athleteID = athleteID
            treatment?.info = info
            treatment?.date = date
            treatment?.treatment = treatmentStr

            if treatment != nil {
                dbManager.updateTreatment(treatment: treatment!)
            }
        }

        self.navigationController?.popViewController(animated: true)
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
        case .treatmentPickerSegue:
            if let treatmentPickerVC = segue.destination as? TreatmentPickerViewController {
                treatmentPickerVC.delegate = self
            }
        }
    }
}

extension AddTreatmentViewController: AthletePickerDelegate {
    func athletePicker(didFinishSelectingWith athlete: UserModel) {
        guard let athlete = athlete as? StudentModel else { return }
        selectedAthlete = athlete
    }

    func athletePickerDidCancel() {
        // Nothing to do right now
    }
}

extension AddTreatmentViewController: TreatmentPickerViewControllerDelegate {
    func finishedPickingTreatment(_ treatment: String) {
        treatmentNameLabel.text = treatment
        treatmentNameLabel.isHidden = false
    }
}
