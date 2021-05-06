//
//  MainMapKitDataManager.swift
//  RideIn
//
//  Created by Алекс Ломовской on 05.05.2021.
//

import UIKit
import MapKit

final class MainMapKitDataManager: MapKitDataManager {
    
    weak var parentDataProvider: MapKitDataProvider?
    
    /// This method creates and  adds an annotation to mapView with given coordinates
    /// - Parameter location: location of type CLLocationCoordinate2D
    func addAnnotation(location: CLLocationCoordinate2D) {
        guard let vc = parentDataProvider?.parentVC as? MapViewController else { return }
        guard parentDataProvider != nil else { return }
        let annotations = parentDataProvider!.annotations
        let annotation = MKPointAnnotation()
        let coordinates = CLLocation(latitude: location.latitude, longitude: location.longitude)
        vc.mapView.removeAnnotations(annotations)
        annotation.coordinate = location
        lookUpForLocation(by: coordinates) { [unowned self] (placemark) in
            guard let placemark = placemark else { return }
            annotation.title = placemark.name
            vc.searchTF.text = placemark.name
            vc.proceedButton.isHidden = false
            parentDataProvider?.selectedPin = MKPlacemark(placemark: placemark)
            vc.mapView.addAnnotation(annotation)
        }
    }
    
    /// This method creates and returns a placemark with given coordinates
    /// - Parameters:
    ///   - coordinates: coordinates to search
    ///   - completionHandler: the escaping handler to operate with location via placemark
    func lookUpForLocation(by coordinates: CLLocation?, completionHandler: @escaping (CLPlacemark?) -> Void) {
        // Use the last reported location.
        if let lastLocation = coordinates {
            let geocoder = CLGeocoder()
            // Look up the location and pass it to the completion handler
            geocoder.reverseGeocodeLocation(lastLocation, completionHandler: { (placemarks, error) in
                if error == nil {
                    let firstLocation = placemarks?[0]
                    completionHandler(firstLocation)
                } else {
                    print("An error occurred during geocoding.")
                    completionHandler(nil)
                }
            })
        } else {
            print("No location was available.")
            completionHandler(nil)
        }
    }
    
    /// This method creates a route on MapView between two placemarks
    /// - Parameters:
    ///   - pickUpPlacemark: first placemark
    ///   - destinationPlacemark: second placemark
    func showRouteOnMap(pickUpPlacemark: MKPlacemark, destinationPlacemark: MKPlacemark) {
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: pickUpPlacemark)
        request.destination = MKMapItem(placemark: destinationPlacemark)
        request.requestsAlternateRoutes = true
        request.transportType = .automobile
        let directions = MKDirections(request: request)
        
        directions.calculate { [unowned self] response, error in
            guard let unwrappedResponse = response else { print("error rotes"); return }
            guard let vc = parentDataProvider?.parentVC as? MapViewController else { return }
            if let route = unwrappedResponse.routes.first {
                vc.mapView.addOverlay(route.polyline)
                vc.mapView.setVisibleMapRect(route.polyline.boundingMapRect,
                                               edgePadding: UIEdgeInsets.init(top: 80.0, left: 20.0, bottom: 100.0, right: 20.0), animated: true)
            }
        }
    }
    
    /// This method is user for dropping pin on mapView and either zoom in it or not
    /// - Parameters:
    ///   - placemark: the placemark with which to create annotation
    ///   - zoom: zoom or not with bool value
    func dropPinZoomIn(placemark: MKPlacemark, zoom: Bool) {
        parentDataProvider?.selectedPin = placemark
        let annotation = MKPointAnnotation()
        annotation.coordinate = placemark.coordinate
        annotation.title = placemark.name
        if let city = placemark.locality,
           let administrativeArea = placemark.administrativeArea {
            annotation.subtitle = "\(city) \(administrativeArea)"
        }
        guard let vc = parentDataProvider?.parentVC as? MapViewController else { return }
        vc.mapView.addAnnotation(annotation)
        if zoom {
            let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
            let region = MKCoordinateRegion(center: placemark.coordinate, span: span)
            vc.mapView.setRegion(region, animated: true)
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
    
    func getLocations(trip: Trip?, completion: @escaping (MKPlacemark, MKPlacemark, Int) -> Void) {
        guard let depLatitude = trip?.waypoints.first?.place.latitude,
              let depLongitude = trip?.waypoints.first?.place.longitude,
              let arriveLatitude = trip?.waypoints.last?.place.latitude,
              let arriveLongitude = trip?.waypoints.last?.place.longitude
        else { return }
        
        let depCoordinates = CLLocationCoordinate2D(latitude: depLatitude, longitude: depLongitude)
        let depPlacemark = MKPlacemark(coordinate: depCoordinates)
        let destCoordinates = CLLocationCoordinate2D(latitude: arriveLatitude, longitude: arriveLongitude)
        let destPlacemark = MKPlacemark(coordinate: destCoordinates)
        let distance = getDistanceBetween(departureLocation: depCoordinates, destinationLocation: destCoordinates)
        let distanceString = String(NSString(format: "%.2f", distance))
        guard let distanceDouble = Double(distanceString) else { return }
        let distanceInt = Int((distanceDouble / 1000).rounded())
        
        completion(depPlacemark, destPlacemark, distanceInt)
    }
    
}
