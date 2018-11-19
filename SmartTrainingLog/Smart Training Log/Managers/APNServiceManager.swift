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
        completionHandler()
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {

        let content = notification.request.content

        let userInfo = content.userInfo
        //let notificationID = userInfo[gcmMessageIDKey]
        // Present notification
        completionHandler(.badge)
    }
}

extension NSNotification.Name {
    static let MessagingTokenDidChange = NSNotification.Name(rawValue: "MessagingTokenDidChange")
}
