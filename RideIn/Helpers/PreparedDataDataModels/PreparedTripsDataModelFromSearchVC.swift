//
//  PreparedTripsDataModelFromSearchVC.swift
//  RideIn
//
//  Created by Алекс Ломовской on 06.05.2021.
//

import Foundation

/// The data prepared for being passed to TripsViewController
struct PreparedTripsDataModelFromSearchVC {
  let delegate: RideSearchDelegate?
  let unsortedTrips: [Trip]
  let cheapToTop: [Trip]
  let expensiveToTop: [Trip]
  let closestTrip: Trip?
  let cheapestTrip: Trip?
  var date: String?
  let departurePlaceName: String?
  let destinationPlaceName: String?
  let passengersCount: Int
  
  init(unsortedTrips: [Trip] = [], cheapToTop: [Trip] = [],
       expensiveToTop: [Trip] = [], closestTrip: Trip? = nil,
       cheapestTrip: Trip? = nil, date: String? = nil,
       departurePlaceName: String? = nil, destinationPlaceName: String? = nil,
       passengersCount: Int = 0, delegate: RideSearchDelegate? = nil) {
    self.unsortedTrips = unsortedTrips
    self.cheapToTop = cheapToTop
    self.expensiveToTop = expensiveToTop
    self.closestTrip = closestTrip
    self.cheapestTrip = cheapestTrip
    self.departurePlaceName = departurePlaceName
    self.destinationPlaceName = destinationPlaceName
    self.passengersCount = passengersCount
    self.delegate = delegate
  }
}




