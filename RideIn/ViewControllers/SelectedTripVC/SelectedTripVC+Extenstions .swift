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
        navigationController?.popViewController(animated: true)
    }
    
    /**
     This method is used for preparing data to be displayed on MapVC
     and preparing the MapVC to be pushed to hierarchy.
     - Here data are processed to be convented to matching types for being able to be displayed on MapVC
     - Also this method creates departure and destination placemarks
     - Calls MapVC "dropPinAndZoom" method to add 2 pins and then show route between them
     */
    @objc final func showMap(sender: UIButton) {
        let vc = MapViewController()
        guard let depLatitude = selectedTrip?.waypoints.first?.place.latitude,
              let depLongitude = selectedTrip?.waypoints.first?.place.longitude,
              let arriveLatitude = selectedTrip?.waypoints.last?.place.latitude,
              let arriveLongitude = selectedTrip?.waypoints.last?.place.longitude
        else { return }
        let depCoordinates = CLLocationCoordinate2D(latitude: depLatitude, longitude: depLongitude)
        let depPlacemark = MKPlacemark(coordinate: depCoordinates)
        let destCoordinates = CLLocationCoordinate2D(latitude: arriveLatitude, longitude: arriveLongitude)
        let destPlacemark = MKPlacemark(coordinate: destCoordinates)
        let distance = getDistanceBetween(departureLocation: depCoordinates, destinationLocation: destCoordinates)
        let distanceString = String(NSString(format: "%.2f", distance))
        if let distanceDouble = Double(distanceString) { vc.distance = Int((distanceDouble / 1000).rounded()) }
        vc.gestureRecognizerEnabled = false
        vc.mapView.showsTraffic = true
        vc.ignoreLocation = true
        vc.distanceSubviewIsHidden = false
        vc.textFieldActivationObserverEnabled = false
        
        switch sender {
        case departurePlaceMapButton:
            vc.searchTF.text = selectedTrip?.waypoints.first?.place.address
            vc.dropPinZoomIn(placemark: destPlacemark, zoom: false)
            vc.dropPinZoomIn(placemark: depPlacemark, zoom: true)
            vc.showRouteOnMap(pickUpPlacemark: depPlacemark, destinationPlacemark: destPlacemark)
            navigationController?.pushViewController(vc, animated: true)
            
        case destinationPlaceMapButton:
            vc.searchTF.text = selectedTrip?.waypoints.last?.place.address
            vc.dropPinZoomIn(placemark: depPlacemark, zoom: false)
            vc.dropPinZoomIn(placemark: destPlacemark, zoom: true)
            vc.showRouteOnMap(pickUpPlacemark: depPlacemark, destinationPlacemark: destPlacemark)
            navigationController?.pushViewController(vc, animated: true)
            
        default: break
        }
    }
    
    
    /// This method calculate distance between two points and returns this distance with type CLLocationDistance
    /// - Parameters:
    ///   - departureLocation: first location
    ///   - destinationLocation: second location
    /// - Returns: distance between two locations
    private func getDistanceBetween(departureLocation: CLLocationCoordinate2D, destinationLocation: CLLocationCoordinate2D) -> CLLocationDistance {
        let departureLocationCoordinates = CLLocation(latitude: departureLocation.latitude, longitude: departureLocation.longitude)
        let destinationLocationCoordinates = CLLocation(latitude: destinationLocation.latitude, longitude: destinationLocation.longitude)
        return destinationLocationCoordinates.distance(from: departureLocationCoordinates)
    }
    
}

