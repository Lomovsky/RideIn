//
//  DistanceCalculator.swift
//  RideIn
//
//  Created by Алекс Ломовской on 06.05.2021.
//

import MapKit

protocol DistanceCalculator {
    func compareDistances(first: CLLocationDistance, second: CLLocationDistance) -> Bool
    func getDistanceBetween(userLocation: CLLocation, departurePoint: CLLocation) -> CLLocationDistance
}

//MARK:- MainDistanceCalculator
struct MainDistanceCalculator: DistanceCalculator {
    
    func compareDistances(first: CLLocationDistance, second: CLLocationDistance) -> Bool {
        return second.isLess(than: first)
    }
    
    func getDistanceBetween(userLocation: CLLocation, departurePoint: CLLocation) -> CLLocationDistance {
        return userLocation.distance(from: departurePoint)
    }
}
