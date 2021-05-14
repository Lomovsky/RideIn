//
//  Notifications.swift
//  RideIn
//
//  Created by Алекс Ломовской on 12.05.2021.
//

import UIKit
import UserNotifications

protocol NotificationsController: UNUserNotificationCenterDelegate {
    var notificationCenter: UNUserNotificationCenter { get }
    func scheduleNotification(ofType type: Notifications)
}

//MARK:- MainNotificationsController
final class MainNotificationsController: NSObject, NotificationsController {
    
    let notificationCenter = UNUserNotificationCenter.current()
        
    func requestNotifications() {
        let options: UNAuthorizationOptions = [.alert, .sound, .badge]
        notificationCenter.requestAuthorization(options: options) { [unowned self] (didAllow, error) in
            if !didAllow {
                self.getNotificationSettings()
            }
        }
    }
    
    func scheduleNotification(ofType type: Notifications) {
        switch type {
        case .newRidesAvailable: scheduleNewRidesNotification()
        }
    }
    
    private func getNotificationSettings() {
        notificationCenter.getNotificationSettings { (settings) in
            if settings.authorizationStatus != .authorized {
                Log.w("Notifications are not allowed")
            }
        }
    }
    
    private func scheduleNewRidesNotification() {
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        
        let notificationRequestFactory = MainNotificationRequestFactory(notificationCenter: notificationCenter,
                                                                        identifier: "Local Notification",
                                                                        trigger: trigger,
                                                                        contentCategoryIdentifier: "UserActions")
        notificationRequestFactory.addAction(identifier: "Find",
                                             title: NSLocalizedString("Notification.Find", comment: ""), options: [.foreground])
        notificationRequestFactory.addAction(identifier: "Dismiss",
                                             title: NSLocalizedString("Notification.Dismiss", comment: ""), options: [.destructive])
        
        let request = notificationRequestFactory.makeNotification(withTitle: NSLocalizedString("Notification.Greetings", comment: ""),
                                                                  body: NSLocalizedString("Notification.NewRidesAvailable", comment: ""))
        requestNotification(with: request)
    }
    
    private func requestNotification(with request: UNNotificationRequest) {
        notificationCenter.add(request) { (error) in
            if let error = error {
                print("Error \(error.localizedDescription)")
            }
        }
    }
}

//MARK:- UNUserNotificationCenterDelegate
extension MainNotificationsController {
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions
                                ) -> Void) {
        completionHandler([.badge, .sound])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        if response.notification.request.identifier == "Local Notification" {
            switch response.actionIdentifier {
            case "Dismiss":
                Log.i("Dismissed")
                
            case "Find":
                let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as! SceneDelegate
                sceneDelegate.coordinatorFactory = CoordinatorFactoryImp(navigationController: UINavigationController(),
                                                                          deepLinkOptions: .notification(.newRidesAvailable))
                
                Log.i("Find a ride triggered")
                
            default:
                Log.i("Unknown action")
            }
            completionHandler()
        }
    }
}
