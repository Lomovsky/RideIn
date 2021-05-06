//
//  MainMapKitDataProvider.swift
//  RideIn
//
//  Created by Алекс Ломовской on 05.05.2021.
//

import UIKit
import MapKit

final class MainMapKitDataProvider: NSObject, MapKitDataProvider {
    
    //MARK: Declarations -
    /// Location manager
    var locationManager: CLLocationManager = LocationManager()
    
    /// MapKit data manager which is responsible for adding pins and rendering routes
    lazy var mapKitDataManager = makeMapKitDataManager()
    
    /// Annotations array to make placemarks
    var annotations = [MKAnnotation]()
    
    /// A pin that user added to mapKit to select rather departure or destination place
    var selectedPin: MKPlacemark?
    
    //The properties user for reusing MapVC for different needs (in this case to use on both RideSearchVC and TripVC)
    /// Ignores user location to prevent focusing on it
    var ignoreLocation = false
    
    var canBeLocated = Bool()
    
    ///Distance between department and destination points to display on top of MapView
    var distance = Int()
    
    /// The viewController which calls dataProvider methods
    weak var parentVC: UIViewController?
    
    //MARK: methods -
    func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    func retriveCurrentLocation() {
        guard let vc = parentVC as? MapViewController else { return }
        let status = locationManager.authorizationStatus

        if(status == .denied || status == .restricted || !CLLocationManager.locationServicesEnabled()) {
            vc.onAlert?()
            canBeLocated = false
            vc.changeFocusOnUsersLocationButton(toEnabled: canBeLocated)
            return
        }
        if(status == .notDetermined) {
            locationManager.requestWhenInUseAuthorization()
            canBeLocated = false
            vc.changeFocusOnUsersLocationButton(toEnabled: canBeLocated)
            return
        }
        locationManager.requestLocation()
        canBeLocated = true
        vc.changeFocusOnUsersLocationButton(toEnabled: canBeLocated)

        if let location = locationManager.location {
            let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
            let region = MKCoordinateRegion(center: location.coordinate, span: span)
            
            let clRegion = CLCircularRegion(center: region.center, radius: 100, identifier: "foo")
            locationManager.startMonitoring(for: clRegion)
            locationManager.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        retriveCurrentLocation()
    }
    
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        retriveCurrentLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let vc = parentVC as? MapViewController else { return }
        guard !ignoreLocation else { return }
        guard let location = locations.first else { return }
        let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        let region = MKCoordinateRegion(center: location.coordinate, span: span)
        vc.mapView.setRegion(region, animated: true)
        locationManager.stopUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("error is \(error)")
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard annotation is MKPointAnnotation else { print("no mkpointannotaions"); return nil }
        let reuseId = "pin"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        
        guard pinView == nil else { pinView!.annotation = annotation; return pinView }
        pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
        pinView!.canShowCallout = true
        pinView!.rightCalloutAccessoryView = UIButton(type: .infoDark)
        pinView!.pinTintColor = .systemRed
        return pinView
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        print("tapped on pin ")
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = .lightBlue
        renderer.lineWidth = 5
        return renderer
    }
    

}

private extension MainMapKitDataProvider {
    
    func makeMapKitDataManager() -> MapKitDataManager {
        let manager = MainMapKitDataManager()
        manager.parentDataProvider = self
        return manager
    }
}
