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
            onMapSelected?(.department, controllerDataProvider.selectedTrip)
            
        case destinationPlaceMapButton:
            onMapSelected?(.destination, controllerDataProvider.selectedTrip)
            
        default: break
            
        }
    }
}

extension SelectedTripViewController: ControllerConfigurable {
    
    func configure(with object: PreparedTripsDataModelFromTripsVC) {
        controllerDataProvider.date = object.date
        controllerDataProvider.arrivingTime = object.arrivingTime
        controllerDataProvider.departurePlace = object.departurePlace
        controllerDataProvider.destinationPlace = object.destinationPlace
        controllerDataProvider.departureTime = object.departureTime
        controllerDataProvider.passengersCount = object.passengersCount
        controllerDataProvider.priceForOne = object.price
        controllerDataProvider.selectedTrip = object.selectedTrip
    }
}
