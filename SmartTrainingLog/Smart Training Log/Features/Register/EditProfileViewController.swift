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

    var imagePickerVC = UIImagePickerController()
    // MARK: - Lifecycle

    override func viewDidLoad() {
        if let authStore = try? Container.resolve(AuthenticationStore.self),
            let user = authStore.user {
            nameField.text = user.displayName
            downloadImage(with: user.photoURL)
        }

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

    private func downloadImage(with url: URL?) {
        guard
            let url = url,
            let fileManager = try? Container.resolve(CloudStorageManager.self)
        else {
            return
        }

        fileManager.getProfilePicture(url: url, handler: { [weak self] (image) in
            if let image = image {
                self?.profileImageView.image = image
            }
        })
    }

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
            let authStore = try? Container.resolve(AuthenticationStore.self),
            let storageManager = try? Container.resolve(CloudStorageManager.self),
            let user = authStore.user {

            // Upload profile picture
            storageManager.saveProfilePicture(image: image, user: user)

            // Save sport choice
            if let dataManager = try? Container.resolve(DatabaseManager.self) {
                dataManager.updateUserSport(user: user, sport: sport)
            }

            // Change profile
            let request = user.createProfileChangeRequest()
            request.displayName = name
            request.photoURL = storageManager.getProfileImageURL(user: user)
            request.commitChanges(completion: nil)

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
