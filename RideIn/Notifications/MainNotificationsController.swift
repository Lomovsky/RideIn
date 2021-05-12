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
        
        let findARideActions = UNNotificationAction(identifier: "Find a ride",
                                                    title: NSLocalizedString("Notification.Find", comment: ""), options: [.foreground])
        let dismissAction = UNNotificationAction(identifier: "Dismiss",
                                                 title: NSLocalizedString("Notification.Dismiss", comment: ""), options: [.destructive])
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        
        let notificationRequestFactory = MainNotificationRequestFactory(notificationCenter: notificationCenter,
                                                                        identifier: "Local Notification",
                                                                        trigger: trigger,
                                                                        contentCategoryIdentifier: "UserActions",
                                                                        actions: [findARideActions, dismissAction])
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
                
            case "Find a ride":
                guard let rootNavigation = UIApplication.shared.windows.first?.rootViewController as? UINavigationController else { return }
                guard let rootVC = rootNavigation.viewControllers.first as? RideSearchViewController else { return }
                rootVC.departureTextField.isSelected = true
                rootVC.departureTextField.becomeFirstResponder()
                rootVC.animate(textField: rootVC.departureTextField)
                rootVC.controllerDataProvider.placeType = .department
                Log.i("Find a ride triggered")
                
            default:
                Log.i("Unknown action")
            }
            completionHandler()
        }
    }
}
