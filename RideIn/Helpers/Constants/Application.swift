//
//  Application.swift
//  RideIn
//
//  Created by Алекс Ломовской on 18.05.2021.
//

import Foundation

/// Represents the users authorization status
enum AuthorizationStatus {
  static var isAuthorized = false
}

enum OnboardingStatus {
  static var onBoardingWasShown = false
}

/// Deep link options
enum DeepLinkOptions {
  case notification(Notifications)
}

/// LogEvent
enum LogEvent: String {
  case e = "[‼️]" // error
  case i = "[ℹ️]" // info
  case d = "[💬]" // debug
  case v = "[🔬]" // verbose
  case w = "[⚠️]" // warning
  
  var value: String {
    get {
      return self.rawValue;
    }
  }
}
