//
//  PreparedTripsDataModelFromSearchVC.swift
//  RideIn
//
//  Created by Алекс Ломовской on 06.05.2021.
//

import Foundation

/// The data prepared for being passed to TripsViewController
struct PreparedTripsDataModelFromSearchVC {
    
    var delegate: RideSearchDelegate?
    var unsortedTrips: [Trip]
    var cheapToTop: [Trip]
    var expensiveToTop: [Trip]
    var closestTrip: Trip?
    var cheapestTrip: Trip?
    var date: String?
    var departurePlaceName: String?
    var destinationPlaceName: String?
    var passengersCount: Int
    
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




