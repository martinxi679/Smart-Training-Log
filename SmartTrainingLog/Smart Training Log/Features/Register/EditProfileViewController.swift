//
//  EditProfileViewController.swift
//  Smart Training Log
//

import UIKit
import Observable

class EditProfileViewController: UIViewController {

    // MARK: - Outlets

    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var sportPickerView: UIPickerView!
    @IBOutlet weak var selectSportLabel: UILabel!

    var imagePickerVC = UIImagePickerController()
    var viewModel = ProfileViewModel()

    var disposeBag: Disposal = []
    // MARK: - Lifecycle

    override func viewDidLoad() {
        var mediaOptions: [String] = []
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            if let media = UIImagePickerController.availableMediaTypes(for: .photoLibrary) {
            mediaOptions.append(contentsOf: media)
            }
        }
        if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum) {
            if let media = UIImagePickerController.availableMediaTypes(for: .savedPhotosAlbum) {
                mediaOptions.append(contentsOf: media)
            }
        }

        // Hide sport picker options for trainers who don't need them
        selectSportLabel.isHidden = viewModel.user?.isTrainer ?? false
        sportPickerView.isHidden = viewModel.user?.isTrainer ?? false


        imagePickerVC.mediaTypes = mediaOptions
        imagePickerVC.delegate = self

        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .done, target: self, action: #selector(updateAndSave))

        sportPickerView.dataSource = self
        sportPickerView.delegate = self

        viewModel.image.observe { [weak self] (image, _) in
            if image != nil {
                self?.profileImageView.image = image
            }
        }.add(to: &disposeBag)

        viewModel.name.observe { [weak self] (name, _) in
            self?.nameField.text = name
        }.add(to: &disposeBag)

        viewModel.sport.observe { [weak self] (sport, _) in
            guard let sport = Sport(rawValue: sport ?? "") else { return }
            self?.sportPickerView.selectRow(Sport.allCases.firstIndex(of: sport) ?? 0, inComponent: 0, animated: false)
        }.add(to: &disposeBag)
    }

    // MARK: - Actions

    @IBAction func pickProfileImage(_ sender: Any) {
        // Implement picture upload on firebase
        if UIDevice.current.userInterfaceIdiom == .pad {
            // Use popover
            imagePickerVC.modalPresentationStyle = .popover
            imagePickerVC.popoverPresentationController?.sourceView = profileImageView
        } else {
            imagePickerVC.modalPresentationStyle = .overFullScreen
        }
        self.present(imagePickerVC, animated: true, completion: nil)
    }

    // MARK: - Private

    @objc
    private func updateAndSave() {
        let sport = Sport.allCases[sportPickerView.selectedRow(inComponent: 0)]

        if
            let storageManager = try? Container.resolve(CloudStorageManager.self),
            var user = viewModel.user as? UserFlyweight {

            // Update user sport and name
            user.sport = sport

            if let name = nameField.text {
                user.name = name
            }

            // Upload profile picture
            if let image = profileImageView.image {
                storageManager.saveProfilePicture(image: image, user: user)
                if let authStore = try? Container.resolve(AuthenticationStore.self) {
                    authStore.cachedProfilePicture.value = image
                }
            }

            // Save user
            if let dataManager = try? Container.resolve(DatabaseManager.self) {
                dataManager.updateUser(user)
            }

            self.navigationController?.popViewController(animated: true)
        }
    }
}

extension EditProfileViewController: UIPickerViewDataSource, UIPickerViewDelegate {

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return Sport.allCases.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return Sport.allCases[row].rawValue
    }

}

extension EditProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            profileImageView.image = image
        }
        picker.dismiss(animated: true, completion: nil)
    }
}
