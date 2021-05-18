//
//  PreparedTripsDataModelFromTripsVC.swift
//  RideIn
//
//  Created by Алекс Ломовской on 11.05.2021.
//

import Foundation

/// The data prepared for being passed to SelectedTripViewController
struct PreparedTripsDataModelFromTripsVC {
  let selectedTrip: Trip?
  let date: String
  let passengersCount: Int
  let departurePlace: String
  let destinationPlace: String
  let departureTime: String
  let arrivingTime: String
  let price: Float
  
  init(selectedTrip: Trip? = nil, date: String = "",
       passengersCount: Int = 0, departurePlace: String = "",
       destinationPlace: String = "", departureTime: String = "",
       arrivingTime: String = "", price: Float = 0.0) {
    self.selectedTrip = selectedTrip
    self.date = date
    self.passengersCount = passengersCount
    self.departurePlace = departurePlace
    self.destinationPlace = destinationPlace
    self.departureTime = departureTime
    self.arrivingTime = arrivingTime
    self.price = price
  }
}
