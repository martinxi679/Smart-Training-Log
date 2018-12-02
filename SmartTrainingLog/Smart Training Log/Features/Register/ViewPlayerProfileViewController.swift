//
//  ViewPlayerProfileViewController.swift
//  Smart Training Log
//

import UIKit
import Observable

class ViewPlayerProfileViewController: UIViewController {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var profileImageView: CircleImageView!
    @IBOutlet weak var sportLabel: UILabel!

    @IBOutlet weak var tableView: UITableView!

    var disposeBag: Disposal = []

    var athlete: UserFlyweight? {
        didSet {
            if let user = athlete {
                treatmentViewModel = AllTreatmentsViewModel(athlete: user)
                if isViewLoaded {
                    update()
                }
            }
        }
    }

    var treatmentViewModel: AllTreatmentsViewModel? {
        willSet {
            treatmentViewModel?.refreshed.removeAllObservers()
        }
        didSet {
            treatmentViewModel?.refreshed.observe({ [weak self] (refreshed, _) in
                if refreshed {
                    self?.tableView.reloadData()
                }
            }).add(to: &disposeBag)

            if isViewLoaded {
                tableView.reloadData()
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(UINib(nibName: "AllTreatmentsTableViewCell", bundle: nil), forCellReuseIdentifier: "AllTreatmentsTableViewCell")

        //setup
        update()
    }

    private func update() {
        nameLabel.text = athlete?.name
        sportLabel.text = athlete?.sport?.rawValue
        if let navItem = navigationController?.navigationItem {
            navItem.title = athlete?.name
        }

        getProfileImage()
    }

    private func getProfileImage() {
        guard let cloudManager = try? Container.resolve(CloudStorageManager.self) else { return }
        guard let user = athlete else { return }
        guard let url = cloudManager.getProfileImageURL(user: user) else { return }

        cloudManager.getProfilePicture(url: url, handler: { [weak self] (image) in
            guard let image = image else { return }
            self?.profileImageView.image = image
        })
    }
}

extension ViewPlayerProfileViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return treatmentViewModel?.getAllTreatments().count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AllTreatmentsTableViewCell", for: indexPath) as! AllTreatmentsTableViewCell

        if let treatment = treatmentViewModel?.treatment(atIndexPath: indexPath),
            let athlete = self.athlete {
            cell.configure(with: treatment, athlete: athlete)
        }

        return cell
    }
}
