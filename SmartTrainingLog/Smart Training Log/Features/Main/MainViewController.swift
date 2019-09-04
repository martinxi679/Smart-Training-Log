//
//  MainViewController.swift
//  Smart Training Log
//

import UIKit

class MainViewController: UITabBarController {

    var treatments: [TreatmentModel] = []

    let queue = DispatchQueue(label: "main VC treatments queue")

    var currentTreatment: TreatmentModel? {
        didSet {
            if checkInAlertVC != nil && !(checkInAlertVC?.isBeingPresented ?? false) {
                checkInAlertVC = nil
            }

            if var treatment = currentTreatment,
                let treatmentStr = treatment.treatment,
                let date = treatment.date,
                checkInAlertVC == nil
            {
                let min = date.minutesTill()
                checkInAlertVC = UIAlertController(title: "You have an appointment", message: "A \(treatmentStr) is scheduled in \(min) minutes. Please check in!", preferredStyle: .alert)

                checkInAlertVC?.addAction(UIAlertAction(title: "Check in", style: .default, handler: { [weak self] _ in
                    if let dataManager = try? Container.resolve(DatabaseManager.self),
                        let user = (try? Container.resolve(AuthenticationStore.self))?.currentUser {
                        dataManager.checkin(user: user, treatment: &treatment)
                    }

                    self?.checkInAlertVC?.dismiss(animated: true, completion: nil)
                }))
                checkInAlertVC?.addAction(UIAlertAction(title: "Cancel", style: .destructive, handler: { [weak self] _ in
                    self?.checkInAlertVC?.dismiss(animated: true, completion: nil)
                }))

                self.present(checkInAlertVC!, animated: true, completion: nil)
            }
        }
    }

    var checkInAlertVC: UIAlertController?

    var trainerCheckInVC: UIAlertController?

    var myTimer: Timer!
    var updateTimer: Timer!

    override func viewDidLoad() {
        super.viewDidLoad()

        myTimer = Timer.scheduledTimer(withTimeInterval: 60.0, repeats: true, block: { [weak self] _ in
            guard let strongSelf = self else { return }

            var current: TreatmentModel?
            strongSelf.queue.sync {
                current = strongSelf.treatments.first(where: { ($0.date?.isWithinSeconds(60 * 10) ?? false) && !($0.checkin ?? false) })
            }
            if let currentTreatment = current {
                self?.currentTreatment = currentTreatment
            } else {
                if strongSelf.checkInAlertVC?.isBeingPresented ?? false {
                    strongSelf.checkInAlertVC?.dismiss(animated: true, completion: nil)
                }
                strongSelf.checkInAlertVC = nil
            }
        })

        updateTimer = Timer.scheduledTimer(withTimeInterval: 60.0 * 60.0, repeats: true, block: {[weak self] _ in
            if let user = (try? Container.resolve(AuthenticationStore.self))?.currentUser {
                guard let dataManager = try? Container.resolve(DatabaseManager.self) else { return }
                guard let id = user.id?.sha256() else { return }
                guard user.isAthlete else { return }

                dataManager.getTreatments(forUserID: id, completionHandler: { [weak self] treatments in
                    self?.queue.sync {
                        self?.treatments = treatments
                    }
                    self?.timer.fire()
                })
            }
        })

        NotificationCenter.default.addObserver(forName: Notification.Name.TreatmentCheckinRecieved, object: nil, queue: nil, using: { [weak self] notification in
            guard let info = notification.userInfo else { return }
            if let tid = info["tid"] as? String,
                let athleteID = info["athleteID"] as? String {
                guard let dataManager = try? Container.resolve(DatabaseManager.self) else { return }
                dataManager.getTreatment(tid, athleteID: athleteID, completion: { treatment in
                    self?.handleTreatmentCheckin(treatment)
                })
            }
        })

        NotificationCenter.default.addObserver(forName: Notification.Name.NewTreatmentRecieved, object: nil, queue: nil, using: { [weak self] _ in
            self?.updateTimer.fire()
        })

        if let user = (try? Container.resolve(AuthenticationStore.self))?.currentUser {
            if user.entitlement == Entitlement.admin {
                //Add admin tab
                let adminStoryboard = UIStoryboard(name: "AdminMain", bundle: nil)
                if let adminVC = adminStoryboard.instantiateInitialViewController() {
                    viewControllers?.insert(adminVC, at: 0)
                }
            }
        }

        if let user = (try? Container.resolve(AuthenticationStore.self))?.currentUser {
            guard let dataManager = try? Container.resolve(DatabaseManager.self) else { return }
            guard let id = user.id?.sha256() else { return }
            guard user.isAthlete else { return }

            dataManager.getTreatments(forUserID: id, completionHandler: { [weak self] treatments in
                self?.queue.sync {
                    self?.treatments = treatments
                }
                self?.timer.fire()
            })
        }
    }

    deinit {
        timer.invalidate()
        updateTimer.invalidate()
    }

    private func handleTreatmentCheckin(_ treatment: TreatmentModel) {

        guard let athleteID = treatment.athleteID else { return }

        if let athleteViewModel = try? Container.resolve(AllAthletesViewModel.self),
            let athlete = athleteViewModel.athleteByHashID(athleteID),
            let name = athlete.name,
            let treatmentStr = treatment.treatment,
            let date = treatment.date {
                let min = date.minutesTill()
                trainerCheckInVC = UIAlertController(title: "Student Checked In", message: "\(name) checked in for their appointment for \(treatmentStr) in \(min) minutes.", preferredStyle: .alert)

                trainerCheckInVC?.addAction(UIAlertAction(title: "Start appointment", style: .default, handler: { [weak self] _ in

                    if let dataManager = try? Container.resolve(DatabaseManager.self) {
                        var flyweight = TreatmentFlywieght()
                        flyweight.update(with: treatment)
                        flyweight.complete = true
                        dataManager.updateTreatment(treatment: flyweight)
                    }
                    self?.trainerCheckInVC?.dismiss(animated: true, completion: nil)
                    self?.trainerCheckInVC = nil
                }))

                trainerCheckInVC?.addAction(UIAlertAction(title: "Athlete not there", style: .destructive, handler: { [weak self] _ in

                    var comment = CommentFlyweight()
                    comment.content = "Missed appointment"
                    comment.date = Date()
                    comment.trainerID = treatment.trainerID

                    if let dataManager = try? Container.resolve(DatabaseManager.self),
                        let flyweight = treatment as? TreatmentFlywieght {
                        dataManager.addComment(comment: comment, toTreatment: flyweight)
                    }
                    self?.trainerCheckInVC?.dismiss(animated: true, completion: nil)
                    self?.trainerCheckInVC = nil
                }))
            present(trainerCheckInVC!, animated: true, completion: nil)
        }
    }
}
