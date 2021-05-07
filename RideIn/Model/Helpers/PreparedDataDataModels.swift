//
//  PreparedDataDataModels.swift
//  RideIn
//
//  Created by Алекс Ломовской on 06.05.2021.
//

import Foundation

//MARK:- PreparedTripsDataModelFromSearchVC

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

//MARK:- PreparedTripsDataModelFromTripsVC

/// The data prepared for being passed to SelectedTripViewController
struct PreparedTripsDataModelFromTripsVC {
    
    var selectedTrip: Trip?
    var date: String
    var passengersCount: Int
    var departurePlace: String
    var destinationPlace: String
    var departureTime: String
    var arrivingTime: String
    var price: Float
    
    init(selectedTrip: Trip? = nil, date: String = "", passengersCount: Int = 0,
         departurePlace: String = "", destinationPlace: String = "", departureTime: String = "",
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


