//
//  EditProfileViewController.swift
//  Smart Training Log
//

import UIKit

class EditProfileViewController: UIViewController {

    // MARK: - Outlets

    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var sportPickerView: UIPickerView!

    // MARK: - Lifecycle

    override func viewDidLoad() {
        if let authStore = try? Container.resolve(AuthenticationStore.self),
            let user = authStore.user {
            nameField.text = user.displayName
            downloadImage(with: user.photoURL)
        }

        sportPickerView.dataSource = self
        sportPickerView.delegate = self
    }

    // MARK: - Actions

    @IBAction func pickProfileImage(_ sender: Any) {

    }

    private func downloadImage(with url: URL?) {

    }
}

extension EditProfileViewController: UIPickerViewDataSource, UIPickerViewDelegate {

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return Sports.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return Sports.sportForIndex(row)?.rawValue
    }

}
