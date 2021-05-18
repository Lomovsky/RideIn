//
//  MainMapKitDataProvider.swift
//  RideIn
//
//  Created by Алекс Ломовской on 05.05.2021.
//

import UIKit
import MapKit


protocol MapKitDataProvider: MKMapViewDelegate, CLLocationManagerDelegate {
  var annotations: [MKAnnotation] { get }
  var parentVC: UIViewController? { get set }
  var selectedPin: MKPlacemark? { get set }
  var locationManager: CLLocationManager { get }
  var mapKitDataManager: MapKitDataManager { get }
  var ignoreLocation: Bool { get set }
  var distance: Int { get set }
  var canBeLocated: Bool { get }
}

final private class LocationManager: CLLocationManager {}

final class MainMapKitDataProvider: NSObject, MapKitDataProvider {
  //MARK: Declarations -
  /// MapKit data manager which is responsible for adding pins and rendering routes
  lazy var mapKitDataManager = makeMapKitDataManager()
  
  /// The viewController which calls dataProvider methods
  weak var parentVC: UIViewController?
  
  /// Location manager
  var locationManager: CLLocationManager = LocationManager()
  
  /// Annotations array to make placemarks
  var annotations: [MKAnnotation] = []
  
  /// A pin that user added to mapKit to select rather departure or destination place
  var selectedPin: MKPlacemark?
  
  /// Ignores user location to prevent focusing on it
  var ignoreLocation = false
  
  /// This property represents users location availability
  var canBeLocated = Bool()
  
  ///Distance between department and destination points to display on top of MapView
  var distance = Int()
  
  //MARK: methods -
  func setupLocationManager() {
    locationManager.delegate = self
    locationManager.desiredAccuracy = kCLLocationAccuracyBest
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
    Log.e("Error here")
  }
  
  func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
    guard annotation is MKPointAnnotation else { Log.w("no mkpointannotaions"); return nil }
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
  }
  
  func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
    let renderer = MKPolylineRenderer(overlay: overlay)
    renderer.strokeColor = .lightBlue
    renderer.lineWidth = 5
    return renderer
  }
  
  private func retriveCurrentLocation() {
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
}

private extension MainMapKitDataProvider {
  func makeMapKitDataManager() -> MapKitDataManager {
    let manager = MainMapKitDataManager()
    manager.parentDataProvider = self
    return manager
  }
}
