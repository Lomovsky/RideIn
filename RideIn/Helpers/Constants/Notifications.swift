//
//  Notifications.swift
//  RideIn
//
//  Created by Алекс Ломовской on 18.05.2021.
//

import Foundation

/// Notifications
enum Notifications {
  case newRidesAvailable
  //...Other notifications
}

enum NotificationIds {
  static var local = "Local Notification"
}

enum NotificationActions {
  static let find = "Find"
  static let dismiss = "Dismiss"
}
