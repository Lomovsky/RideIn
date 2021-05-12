//
//  NotificationRequestFactory.swift
//  RideIn
//
//  Created by Алекс Ломовской on 12.05.2021.
//

import Foundation
import UserNotifications

protocol NotificationRequestFactory {
    var notificationCenter: UNUserNotificationCenter { get }
    var identifier: String { get }
    var trigger: UNNotificationTrigger { get }
    var contentCategoryIdentifier: String { get }
    var actions: [UNNotificationAction]? { get set }
    func makeNotification(withTitle title: String, body: String) -> UNNotificationRequest
}

//MARK:- NotificationFactory
final class MainNotificationRequestFactory: NotificationRequestFactory {
    
    let notificationCenter: UNUserNotificationCenter
    
    var identifier: String
    
    var trigger: UNNotificationTrigger
    
    var contentCategoryIdentifier: String
    
    var actions: [UNNotificationAction]?
    
    init(notificationCenter: UNUserNotificationCenter,
         identifier: String,
         trigger: UNNotificationTrigger,
         contentCategoryIdentifier: String,
         actions: [UNNotificationAction]? = nil) {
        self.notificationCenter = notificationCenter
        self.identifier = identifier
        self.trigger = trigger
        self.actions = actions
        self.contentCategoryIdentifier = contentCategoryIdentifier
    }
    
    func makeNotification(withTitle title: String, body: String = "") -> UNNotificationRequest {
        let content = UNMutableNotificationContent()
        content.categoryIdentifier = contentCategoryIdentifier
        content.title = title
        content.body = body
        content.sound = UNNotificationSound.default
        content.badge = 1
        if let actionsArray = actions {
            let category = UNNotificationCategory(identifier: contentCategoryIdentifier,
                                                  actions: actionsArray,
                                                  intentIdentifiers: [],
                                                  options: [])
            notificationCenter.setNotificationCategories([category])
        }
        
        return UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
    }
}
