//
//  DeeplinkRouter.swift
//  Smart Training Log
//

import UIKit

class DeeplinkRouter {

    func handle(_ deeplink: Deeplink) {
        guard let mainVC = findMainVC() else { return }
        guard let vcs = mainVC.viewControllers else { return }

        switch deeplink {
        case .profile:
            for vc in vcs {
                if vc.tabBarItem.tag == 0 {
                    mainVC.selectedViewController = vc
                }
            }
        case .editProfile:
            for vc in vcs {
                if vc.tabBarItem.tag == 2 {
                    mainVC.selectedViewController = vc
                    (vc as? ProfileViewController)?.handleDeeplink(deeplink)
                }
            }
        case .admin:
            for vc in vcs {
                if vc.tabBarItem.tag == 4 {
                    mainVC.selectedViewController = vc
                }
            }
        case .adminProfile:
            for vc in vcs {
                if vc.tabBarItem.tag == 4 {
                    mainVC.selectedViewController = vc
                }
            }
        case .manageTeams:
            for vc in vcs {
                if vc.tabBarItem.tag == 4 {
                    mainVC.selectedViewController = vc
                }
            }
        case .teamRoster(_):
            for vc in vcs {
                if vc.tabBarItem.tag == 4 {
                    mainVC.selectedViewController = vc
                }
            }
        case .profileViewTeam(_):
            for vc in vcs {
                if vc.tabBarItem.tag == 0 {
                    mainVC.selectedViewController = vc
                }
            }
        case .profileViewTeamViewAthlete(_, _):
            for vc in vcs {
                if vc.tabBarItem.tag == 0 {
                    mainVC.selectedViewController = vc
                }
            }
        case .viewTreatment(_):
            for vc in vcs {
                if vc.tabBarItem.tag == 1 {
                    mainVC.selectedViewController = vc
                    (vc as? TreatmentsViewController)?.handleDeeplink(deeplink)
                }
            }
        case .editTreatment(_):
            for vc in vcs {
                if vc.tabBarItem.tag == 1 {
                    mainVC.selectedViewController = vc
                    (vc as? TreatmentsViewController)?.handleDeeplink(deeplink)
                }
            }
        case .viewHistory(_):
            for vc in vcs {
                if vc.tabBarItem.tag == 2 {
                    mainVC.selectedViewController = vc
                }
            }
        case .more:
            for vc in vcs {
                if vc.tabBarItem.tag == 3 {
                    mainVC.selectedViewController = vc
                }
            }
            return
        }
    }

    private func findMainVC() -> MainViewController? {
        let root = UIApplication.shared.keyWindow?.rootViewController
        if root is MainViewController {
            return (root as! MainViewController)
        } else if root is UINavigationController {
            if let main = (root as! UINavigationController).viewControllers.first as? MainViewController {
                return main
            }
        } else {
            if let presented = root?.presentedViewController as? MainViewController {
                return presented
            }
        }

        return nil
    }
}

enum Deeplink: Equatable {
    static func == (lhs: Deeplink, rhs: Deeplink) -> Bool {
        switch (lhs, rhs) {
        case (.profile, .profile),
             (.editProfile, .editProfile),
             (.admin, .admin),
             (.adminProfile, .adminProfile),
             (.manageTeams, .manageTeams),
             (.teamRoster(_), .teamRoster(_)),
             (.profileViewTeam(_), .profileViewTeam(_)),
             (.profileViewTeamViewAthlete(_,_), .profileViewTeamViewAthlete(_,_)),
             (.viewTreatment(_), .viewTreatment(_)),
             (.editTreatment(_), .editTreatment(_)),
             (.viewHistory(_), .viewHistory(_)),
             (.more, .more):
            return true
        default: return false
        }
    }

    case profile
    case editProfile
    case admin
    case adminProfile
    case manageTeams
    case teamRoster(String)
    case profileViewTeam(String)
    case profileViewTeamViewAthlete((String, String))
    case viewTreatment(String)
    case editTreatment(String)
    case viewHistory(String)
    case more
}
