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

    @objc final func showMapButtonTapped(sender: UIButton) {
        switch sender {
        case departurePlaceMapButton:
            onMapSelected?(.department, selectedTrip)
            
        case destinationPlaceMapButton:
            onMapSelected?(.destination, selectedTrip)
            
        default: break
            
        }
    }
}

extension SelectedTripViewController: ControllerConfigurable {
    
    func configure(with object: PreparedTripsDataModelFromTripsVC) {
        date = object.date
        arrivingTime = object.arrivingTime
        departurePlace = object.departurePlace
        destinationPlace = object.destinationPlace
        departureTime = object.departureTime
        passengersCount = object.passengersCount
        priceForOne = object.price
        selectedTrip = object.selectedTrip
    }
}
