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
        imagePickerVC.mediaTypes = mediaOptions
        imagePickerVC.delegate = self

        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .done, target: self, action: #selector(updateAndSave))

        sportPickerView.dataSource = self
        sportPickerView.delegate = self

        viewModel.image.observe { [weak self] (image, _) in
            self?.profileImageView.image = image
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
        guard
            let name = nameField.text,
            let image = profileImageView.image
        else {
            return
            // TODO: Show Error
        }
        let sport = Sport.allCases[sportPickerView.selectedRow(inComponent: 0)]

        if
            let storageManager = try? Container.resolve(CloudStorageManager.self),
            var user = viewModel.user {
                user.sport = sport.rawValue
                user.name = name

            let photoStr = storageManager.getProfileImageURL(user: user)?.absoluteString
                user.photoURL = photoStr
            // Upload profile picture
            storageManager.saveProfilePicture(image: image, user: user)

            // Save user
            if
                let dataManager = try? Container.resolve(DatabaseManager.self),
                let model = user as? UserFlyweight {
                dataManager.updateUser(user: model)
            }

            // Change profile
            if let authStore = try? Container.resolve(AuthenticationStore.self) {
                let request = authStore.firebaseUser?.createProfileChangeRequest()
                request?.displayName = name
                request?.photoURL = storageManager.getProfileImageURL(user: user)
                request?.commitChanges(completion: nil)
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
