//
//  APNServiceManager.swift
//  Smart Training Log
//

import Foundation
import FirebaseMessaging
import FirebaseInstanceID
import UserNotifications

class APNServiceManager: NSObject {

    let notificationCenter = UNUserNotificationCenter.current()

    var hasAccess: Bool = false

    var messagingToken: String? {
        didSet {
            NotificationCenter.default.post(name: .MessagingTokenDidChange, object: messagingToken)
        }
    }

    override init() {
        super.init()

        notificationCenter.delegate = (UIApplication.shared.delegate as! AppDelegate)

        let options: UNAuthorizationOptions = [.sound, .badge, .alert]
        notificationCenter.requestAuthorization(options: options, completionHandler: { [weak self] (grantedAccess, _) in
            self?.hasAccess = grantedAccess
            self?.getUpdatedMessagingToken(completion: {_ in })
        })

        UIApplication.shared.registerForRemoteNotifications()
        Messaging.messaging().delegate = (UIApplication.shared.delegate as! AppDelegate)
    }

    func getUpdatedMessagingToken(completion: @escaping (String?) -> Void) {
        InstanceID.instanceID().instanceID { [weak self] (result, error) in
            guard
                let strongSelf = self,
                let result = result,
                error == nil
            else {
                completion(nil)
                return
            }

            strongSelf.messagingToken = result.token
            completion(result.token)
        }
    }
}

extension AppDelegate: MessagingDelegate {
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        guard let apnService = try? Container.resolve(APNServiceManager.self) else { return }
        apnService.messagingToken = fcmToken
    }

    func messaging(_ messaging: Messaging, didReceive remoteMessage: MessagingRemoteMessage) {
        print("received")
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        // Handle user action on notification
        let notification = response.notification
        let userInfo = notification.request.content.userInfo

        if let type = userInfo["aps"] as? [AnyHashable: Any] {
            if let category = type["category"] as? String {
                if category == "NEW_TREATMENT" {
                    if let id = userInfo["treatmentID"] as? String,
                        let athleteID = userInfo["athleteID"] as? String {
                        NotificationCenter.default.post(name: .NewTreatmentRecieved, object: nil, userInfo: ["tid": id, "athleteID": athleteID])

                        if let deeplinkRouter = try? Container.resolve(DeeplinkRouter.self) {
                            deeplinkRouter.handle(Deeplink.viewTreatment(id))
                        }
                    }
                } else if category == "TREATMENT_CHECKIN" {
                    if let id = userInfo["treatmentID"] as? String,
                        let athleteID = userInfo["athleteID"] as? String {
                        NotificationCenter.default.post(name: .TreatmentCheckinRecieved, object: nil, userInfo: ["tid": id, "athleteID": athleteID])
                        if let deeplinkRouter = try? Container.resolve(DeeplinkRouter.self) {
                            deeplinkRouter.handle(Deeplink.viewTreatment(id))
                        }
                    }
                }
            }
        }

        completionHandler()
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {

        let content = notification.request.content

        let userInfo = content.userInfo

        if let type = userInfo["aps"] as? [AnyHashable: Any] {
            if let category = type["category"] as? String {
                if category == "NEW_TREATMENT" {
                    if let id = userInfo["treatmentID"] as? String,
                        let athleteID = userInfo["athleteID"] as? String {
                        NotificationCenter.default.post(name: .NewTreatmentRecieved, object: nil, userInfo: ["tid": id, "athleteID": athleteID])
                    }
                } else if category == "TREATMENT_CHECKIN" {
                    if let id = userInfo["treatmentID"] as? String,
                        let athleteID = userInfo["athleteID"] as? String {
                        NotificationCenter.default.post(name: .TreatmentCheckinRecieved, object: nil, userInfo: ["tid": id, "athleteID": athleteID])
                    }
                }
            }
        }
        completionHandler([])
    }
}

extension NSNotification.Name {
    static let MessagingTokenDidChange = NSNotification.Name(rawValue: "MessagingTokenDidChange")

    static let NewTreatmentRecieved = NSNotification.Name(rawValue: "NewTreatmentRecieved")
    static let TreatmentCheckinRecieved = NSNotification.Name(rawValue: "TreatmentCheckinRecieved")
}
