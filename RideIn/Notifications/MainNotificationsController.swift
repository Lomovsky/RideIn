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
    notificationCenter.requestAuthorization(options: options) { [weak self] (didAllow, error) in
      guard let self = self else { return }
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
    let notificationRequestFactory = MainNotificationRequestFactory(
      notificationCenter: notificationCenter,
      identifier: NotificationIds.local,
      trigger: trigger,
      contentCategoryIdentifier: "UserActions")
    notificationRequestFactory.addAction(
      identifier: NotificationActions.find,
      title: NSLocalizedString(.Localization.Notifications.find, comment: ""),
      options: [.foreground])
    notificationRequestFactory.addAction(
      identifier: NotificationActions.dismiss,
      title: NSLocalizedString(.Localization.Notifications.dismiss, comment: ""),
      options: [.destructive])
    let request = notificationRequestFactory.makeNotification(
      withTitle:NSLocalizedString(.Localization.Notifications.greetings, comment: ""),
      body:NSLocalizedString(.Localization.Notifications.newRidesAvailable, comment: ""))
    
    requestNotification(with: request)
  }
  
  private func requestNotification(with request: UNNotificationRequest) {
    notificationCenter.add(request) { (error) in
      if let error = error {
        Log.e("Error \(error.localizedDescription)")
      }
    }
  }
}

//MARK:- UNUserNotificationCenterDelegate
extension MainNotificationsController {
  func userNotificationCenter(
    _ center: UNUserNotificationCenter,
    willPresent notification: UNNotification,
    withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions
    ) -> Void) {
    completionHandler([.badge, .sound])
  }
  
  func userNotificationCenter(
    _ center: UNUserNotificationCenter,
    didReceive response: UNNotificationResponse,
    withCompletionHandler completionHandler: @escaping () -> Void) {
    if response.notification.request.identifier ==  NotificationIds.local {
      switch response.actionIdentifier {
      case NotificationActions.dismiss:
        break
        
      case NotificationActions.find:
        let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as! SceneDelegate
        sceneDelegate.coordinatorFactory = CoordinatorFactoryImp(
          navigationController: UINavigationController(),
          deepLinkOptions: .notification(.newRidesAvailable))
      default:
        break
      }
      completionHandler()
    }
  }
}
