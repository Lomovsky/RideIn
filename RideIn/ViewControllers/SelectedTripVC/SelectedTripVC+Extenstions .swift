//
//  SelectedTripVC+Extenstions .swift
//  RideIn
//
//  Created by Алекс Ломовской on 23.04.2021.
//

import UIKit
import MapKit

//MARK:- Helping methods
extension SelectedTripViewController {
    
    /// This method is called when back button is pressed
    @objc final func backButtonPressed() {
        onFinish?()
    }
    
    //TODO
    @objc final func showMap(sender: UIButton) {
        switch sender {
        case departurePlaceMapButton:
            onMapSelected?(.department, selectedTrip)
            
        case destinationPlaceMapButton:
            onMapSelected?(.destination, selectedTrip)
            
        default: break
        }
    }
    
    
    /// This method calculate distance between two points and returns this distance with type CLLocationDistance
    /// - Parameters:
    ///   - departureLocation: first location
    ///   - destinationLocation: second location
    /// - Returns: distance between two locations
    func getDistanceBetween(departureLocation: CLLocationCoordinate2D, destinationLocation: CLLocationCoordinate2D) -> CLLocationDistance {
        let departureLocationCoordinates = CLLocation(latitude: departureLocation.latitude, longitude: departureLocation.longitude)
        let destinationLocationCoordinates = CLLocation(latitude: destinationLocation.latitude, longitude: destinationLocation.longitude)
        return destinationLocationCoordinates.distance(from: departureLocationCoordinates)
    }
    
}

