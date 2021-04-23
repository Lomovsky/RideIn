//
//  MapVC+MKExtensions.swift
//  RideIn
//
//  Created by Алекс Ломовской on 15.04.2021.
//

import UIKit
import MapKit

protocol HandleMapSearch {
    func dropPinZoomIn(placemark: MKPlacemark, zoom: Bool)
}


//MARK:- MKHelpingMethods
extension MapViewController {
    
    /// This method is responsible for parsing address to more detailed and user-friendly style
    /// - Parameter selectedItem: the placemark which data will be precessed
    /// - Returns: string address line
    func parseAddress(selectedItem: MKPlacemark) -> String {
        // put a space between "4" and "Melrose Place"
        let firstSpace = (selectedItem.subThoroughfare != nil && selectedItem.thoroughfare != nil) ? " " : ""
        // put a comma between street and city/state
        let comma = (selectedItem.subThoroughfare != nil || selectedItem.thoroughfare != nil) && (selectedItem.subAdministrativeArea != nil || selectedItem.administrativeArea != nil) ? ", " : ""
        // put a space between "Washington" and "DC"
        let secondSpace = (selectedItem.subAdministrativeArea != nil && selectedItem.administrativeArea != nil) ? " " : ""
        let addressLine = String(
            format:"%@%@%@%@%@%@%@",
            // street number
            selectedItem.subThoroughfare ?? "",
            firstSpace,
            // street name
            selectedItem.thoroughfare ?? "",
            comma,
            // city
            selectedItem.locality ?? "",
            secondSpace,
            // state
            selectedItem.administrativeArea ?? ""
        )
        return addressLine
    }
    
    /// This method creates and  adds an annotation to mapView with given coordinates
    /// - Parameter location: location of type CLLocationCoordinate2D
    func addAnnotation(location: CLLocationCoordinate2D) {
        let annotations = self.mapView.annotations
        let annotation = MKPointAnnotation()
        let coordinates = CLLocation(latitude: location.latitude, longitude: location.longitude)
        mapView.removeAnnotations(annotations)
        annotation.coordinate = location
        lookUpForLocation(by: coordinates) { [unowned self] (placemark) in
            guard let placemark = placemark else { return }
            annotation.title = placemark.name
            self.searchTF.text = placemark.name
            self.proceedButton.isHidden = false
            self.selectedPin = MKPlacemark(placemark: placemark)
            self.mapView.addAnnotation(annotation)
        }
    }
    
    /// This method creates and returns a placemark with given coordinates
    /// - Parameters:
    ///   - coordinates: coordinates to search
    ///   - completionHandler: the escaping handler to operate with location via placemark
    private func lookUpForLocation(by coordinates: CLLocation?, completionHandler: @escaping (CLPlacemark?) -> Void ) {
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
}

//MARK:- CLLocationManagerDelegate
extension MapViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            locationManager.requestLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if !ignoreLocation {
            if let location = locations.first {
                let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                let region = MKCoordinateRegion(center: location.coordinate, span: span)
                mapView.setRegion(region, animated: true)
            }
        }
        
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("error is \(error)")
    }
    
}


//MARK:- MKMapViewDelegate
extension MapViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard annotation is MKPointAnnotation else { print("no mkpointannotaions"); return nil }
        
        let reuseId = "pin"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.rightCalloutAccessoryView = UIButton(type: .infoDark)
            pinView!.pinTintColor = .systemRed
        } else {
            pinView!.annotation = annotation
        }
        return pinView
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        print("tapped on pin ")
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
            
            //for getting just one route
            if let route = unwrappedResponse.routes.first {
                //show on map
                self.mapView.addOverlay(route.polyline)
                
                self.mapView.setVisibleMapRect(route.polyline.boundingMapRect,
                                               edgePadding: UIEdgeInsets.init(top: 80.0, left: 20.0, bottom: 100.0, right: 20.0), animated: true)
            }
        }
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = .lightBlue
        renderer.lineWidth = 5
        return renderer
    }
    
}

//MARK:- HandleMapSearch
extension MapViewController: HandleMapSearch {
    
    
    /// This method is user for dropping pin on mapView and either zoom in it or not
    /// - Parameters:
    ///   - placemark: the placemark with which to create annotation
    ///   - zoom: zoom or not with bool value
    func dropPinZoomIn(placemark: MKPlacemark, zoom: Bool) {
        selectedPin = placemark
        let annotation = MKPointAnnotation()
        annotation.coordinate = placemark.coordinate
        annotation.title = placemark.name
        if let city = placemark.locality,
           let administrativeArea = placemark.administrativeArea {
            annotation.subtitle = "\(city) \(administrativeArea)"
        }
        mapView.addAnnotation(annotation)
        if zoom {
            let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
            let region = MKCoordinateRegion(center: placemark.coordinate, span: span)
            mapView.setRegion(region, animated: true)
        }
    }    
    
}


