//
//  SelectedTripViewControllerDataProvider.swift
//  RideIn
//
//  Created by Алекс Ломовской on 07.05.2021.
//

import UIKit

final class SelectedTripViewControllerDataProvider: ControllerDataProvidable {
    
    weak var parentController: UIViewController?
    
    /// The trip which data should be presented
    var selectedTrip: Trip?
    
    /// The date of the trip
    var date = String()
    
    /// The departure time of the trip
    var departureTime = String()
    
    /// The departure place name of the trip
    var departurePlace = String()
    
    /// The arriving time of the trip
    var arrivingTime = String()
    
    /// The destination place
    var destinationPlace = String()
    
    /// Number of passengers requested for a trip
    var passengersCount = Int()
    
    ///Price for one passenger
    var priceForOne = Float()
    
    init(parentController: UIViewController) {
        self.parentController = parentController
    }
}
