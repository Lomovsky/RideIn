//
//  Localization.swift
//  RideIn
//
//  Created by Алекс Ломовской on 18.05.2021.
//

import Foundation

extension String {
  /// Localization extension to simplify access to localizableString keys
  public struct Localization {
    enum Onboarding {
      static let greetings = "Onboarding.greetings"
      static let welcome = "Onboarding.welcome"
      static let next = "Onboarding.next"
      static let whatAppCanDo = "Onboarding.whatAppCanDo"
      static let recommendations = "Onboarding.recommendations"
      static let search = "Onboarding.search"
      static let saveTrips = "Onboarding.saveTrips"
      static let confirm = "Onboarding.confirm"
    }
    
    struct Search {
      static let title = "Search.title"
      static let departure = "Search.departure"
      static let destination = "Search.destination"
      static let searchButton = "Search.searchButton"
      static let showMap = "Search.showMap"
    }
    
    struct Alert {
      static let dismiss = "Alert.dismiss"
      static let error = "Alert.error"
      static let noConnection = "Alert.noConnection"
      static let wrongDataFormat = "Alert.wrongDataFormat"
      static let noTrips = "Alert.noTrips"
      static let locationService = "Alert.locationService"
      static let openSettings = "Alert.openSettings"
    }
    
    struct PassengersCount {
      static let title = "PassengersCountVC.title"
    }
    
    struct Map {
      static let placeholder = "MapVC.searchPlaceholder"
      static let distance = "MapVC.distance"
      static let km = "MapVC.km"
    }
    
    struct Trips {
      static let date = "Date"
      static let cheapestTrip = "TheCheapestTrip"
      static let closestTrip = "TheClosestTrip"
    }
    
    struct SelectedTrip {
      static let total = "TotalPrice"
    }
    
    struct Notifications {
      static let greetings = "Notification.Greetings"
      static let dismiss = "Notification.Dismiss"
      static let find = "Notification.Find"
      static let newRidesAvailable = "Notification.NewRidesAvailable"
    }
  }
  
}

