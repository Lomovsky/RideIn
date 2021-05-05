//
//  DataProviders.swift
//  RideIn
//
//  Created by Алекс Ломовской on 28.04.2021.
//

import UIKit
import MapKit

//MARK:- MainMapKitDataProvider
final class MainMapKitDataProvider: NSObject, MapKitDataProvider {
    
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
    
    func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
    }
    
    func retriveCurrentLocation() {
        guard let vc = parentVC as? MapViewController else { return }
        let status = locationManager.authorizationStatus

        if(status == .denied || status == .restricted || !CLLocationManager.locationServicesEnabled()) {
            vc.present(vc.locationAlert, animated: true)
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
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        retriveCurrentLocation()
    }
    
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        retriveCurrentLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            locationManager.requestLocation()
            locationManager.startUpdatingLocation()
        }
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

//MARK:- RideSearchTableviewDataProvider
final class RideSearchTableviewDataProvider: NSObject, PlacesSearchTableViewDataProvider {
    
    var delegate: RideSearchTableViewDataProviderDelegate?
    
    ///The array of items that match to users search
    var matchingItems = [MKMapItem]()
    
    /// Parent viewController that asks for data
    weak var parentVC: UIViewController?
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return matchingItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: RideSearchTableViewCell.reuseIdentifier, for: indexPath) as! RideSearchTableViewCell
        let place = matchingItems[indexPath.row].placemark
        cell.textLabel?.font = .boldSystemFont(ofSize: 20)
        cell.textLabel?.numberOfLines = 0
        cell.textLabel?.textColor = .darkGray
        if let country = place.country, let administrativeArea = place.administrativeArea, let name = place.name {
            cell.textLabel?.text = "\(country), \(administrativeArea), \(name)"
        } else {
            cell.textLabel?.text = place.name
        }
        cell.detailTextLabel?.text = MainMapKitPlacesSearchManager.parseAddress(selectedItem: place)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let placemark = matchingItems[indexPath.row].placemark
        let latitude = placemark.coordinate.latitude
        let longitude = placemark.coordinate.longitude
        let coordinates = "\(latitude),\(longitude)"
        delegate?.didSelectCell(passedData: placemark.name, coordinates: coordinates)
        Log.i("\(self) selected")
        
        guard let vc = parentVC as? RideSearchViewController else { return }
        switch vc.placeType {
        case .department:
            vc.departureTextField.text = placemark.name
            vc.departureCoordinates = coordinates
            vc.dismissDepartureTextField()
            
        case .destination:
            vc.destinationTextField.text = placemark.name
            vc.destinationCoordinates = coordinates
            vc.dismissDestinationTextField()
            
        default: break
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let vc = parentVC as? RideSearchViewController else { return 0.0 }
        return vc.view.frame.height * 0.07
    }
}

//MARK:- MapTableViewDataProvider
final class MapTableViewDataProvider: NSObject, PlacesSearchTableViewDataProvider {
    
    var delegate: MapTableViewDataProviderDelegate?
    
    ///The array of items that match to users search
    var matchingItems = [MKMapItem]()
    
    /// Parent viewController that asks for data
    weak var parentVC: UIViewController?
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return matchingItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: MapTableViewCell.reuseIdentifier, for: indexPath) as! MapTableViewCell
        let place = matchingItems[indexPath.row].placemark
        cell.textLabel?.text = place.name
        guard let country = place.country, let administrativeArea = place.administrativeArea, let name = place.name else { return cell }
        
        cell.textLabel?.text = ("\(country), \(administrativeArea), \(name)")
        cell.detailTextLabel?.text = MainMapKitPlacesSearchManager.parseAddress(selectedItem: place)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let place = matchingItems[indexPath.row].placemark
        delegate?.didSelectCell(passedData: place)
        guard let vc = parentVC as? MapViewController else { return }
        vc.mapView.removeAnnotations(vc.mapView.annotations)
        vc.mapKitDataProvider.mapKitDataManager.dropPinZoomIn(placemark: place, zoom: true)
        vc.dismissTableView()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let vc = parentVC as? MapViewController else { return 0.0 }
        return vc.searchTF.frame.height
    }
    
}

//MARK:- MainTripsCollectionViewDataProvider
final class MainTripsCollectionViewDataProvider: NSObject, TripsCollectionViewDataProvider {
    
    var delegate: MainTripsCollectionViewDataProviderDelegate?
    
    /// Parent viewController that asks for data
    weak var parentVC: UIViewController?
    
    /// The manager to convent date and time from Trip object to more user-friendly style
    var dateTimeFormatter: DateTimeFormatter = MainDateTimeFormatter()
    
    /// The name of the departure place
    var departurePlaceName = String()
    
    /// The name of destination place
    var destinationPlaceName = String()
    
    /// The base unsorted array of available trips
    var trips = [Trip]()
    
    /// The sorted array of available trips with increasing price
    var cheapTripsToTop = [Trip]()
    
    /// The sorted array of available trips with decreasing price
    var cheapTripsToBottom = [Trip]()
    
    /// The cheapest trip
    var cheapestTrip: Trip?
    
    /// The closest to user departure  point trip
    var closestTrip: Trip?
    
    /// Number of passengers
    var numberOfPassengers = Int()
    
    /// The selected trip departure date
    var date = NSLocalizedString("Date", comment: "")
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let vc = parentVC as? TripsViewController else { return 0 }
        switch collectionView {
        case vc.recommendationsCollectionView: return trips.count == 1 ? 1 :  2
            
        case vc.allTipsCollectionView: return trips.count
            
        case vc.cheapTripsToTopCollectionView: return cheapTripsToTop.count
            
        case vc.cheapTripsToBottomCollectionView: return cheapTripsToBottom.count
            
        default: return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let vc = parentVC as? TripsViewController else { return UICollectionViewCell() }
        switch collectionView {
        case vc.recommendationsCollectionView:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TripCollectionViewCell.recommendationsReuseIdentifier,
                                                          for: indexPath) as! TripCollectionViewCell
            cell.addShadow(color: .black, radius: 4, opacity: 0.1)
            guard trips.count != 1 else { cell.setPlaceholder(); return cell }
            
            let cheapestTripDepartureTimeString = dateTimeFormatter.getDateTime(format: .hhmmss, from: cheapestTrip, for: .department)
            let cheapestTripArrivingTimeString = dateTimeFormatter.getDateTime(format: .hhmmss, from: cheapestTrip, for: .destination)
            let closestTripDepartureTimeString = dateTimeFormatter.getDateTime(format: .hhmmss, from: closestTrip, for: .department)
            let closestTripArrivingTimeString = dateTimeFormatter.getDateTime(format: .hhmmss, from: closestTrip, for: .destination)
            
            if indexPath.row == 0 {
                cell.configureTheCell(departurePlace: departurePlaceName,
                                      arrivingPlace: destinationPlaceName,
                                      departureTime: cheapestTripDepartureTimeString,
                                      arrivingTime: cheapestTripArrivingTimeString,
                                      filterType: NSLocalizedString("TheCheapestTrip", comment: ""),
                                      price: cheapestTrip?.price.amount ?? "")
                
            } else {
                cell.configureTheCell(departurePlace: departurePlaceName,
                                      arrivingPlace: destinationPlaceName,
                                      departureTime: closestTripDepartureTimeString,
                                      arrivingTime: closestTripArrivingTimeString,
                                      filterType: NSLocalizedString("TheClosestTrip", comment: ""),
                                      price: closestTrip?.price.amount ?? "")
            }
            return cell
            
        case vc.allTipsCollectionView:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TripCollectionViewCell.allTripsReuseIdentifier,
                                                          for: indexPath) as! TripCollectionViewCell
            cell.addShadow(color: .black, radius: 5, opacity: 0.4)
            let trip = trips[indexPath.row]
            let tripDepartureTime = dateTimeFormatter.getDateTime(format: .hhmmss, from: trip, for: .department)
            let tripArrivingTime = dateTimeFormatter.getDateTime(format: .hhmmss, from: trip, for: .destination)
            
            cell.configureTheCell(departurePlace: departurePlaceName,
                                  arrivingPlace: destinationPlaceName,
                                  departureTime: tripDepartureTime,
                                  arrivingTime: tripArrivingTime,
                                  filterType: nil,
                                  price: trip.price.amount)
            return cell
            
        case vc.cheapTripsToTopCollectionView:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TripCollectionViewCell.cheapToTopReuseIdentifier,
                                                          for: indexPath) as! TripCollectionViewCell
            cell.addShadow(color: .black, radius: 5, opacity: 0.4)
            let trip = cheapTripsToTop[indexPath.row]
            let tripDepartureTime = dateTimeFormatter.getDateTime(format: .hhmmss, from: trip, for: .department)
            let tripArrivingTime = dateTimeFormatter.getDateTime(format: .hhmmss, from: trip, for: .destination)
            
            cell.configureTheCell(departurePlace: departurePlaceName,
                                  arrivingPlace: destinationPlaceName,
                                  departureTime: tripDepartureTime,
                                  arrivingTime: tripArrivingTime,
                                  filterType: nil,
                                  price: trip.price.amount)
            return cell
            
        case vc.cheapTripsToBottomCollectionView:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TripCollectionViewCell.cheapToBottomReuseIdentifier,
                                                          for: indexPath) as! TripCollectionViewCell
            cell.addShadow(color: .black, radius: 5, opacity: 0.4)
            let trip = cheapTripsToBottom[indexPath.row]
            let tripDepartureTime = dateTimeFormatter.getDateTime(format: .hhmmss, from: trip, for: .department)
            let tripArrivingTime = dateTimeFormatter.getDateTime(format: .hhmmss, from: trip, for: .destination)
            
            cell.configureTheCell(departurePlace: departurePlaceName,
                                  arrivingPlace: destinationPlaceName,
                                  departureTime: tripDepartureTime,
                                  arrivingTime: tripArrivingTime,
                                  filterType: nil,
                                  price: trip.price.amount)
            return cell
            
        default: return UICollectionViewCell()
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let vc = parentVC as? TripsViewController else { return }
        
        switch collectionView {
        case vc.recommendationsCollectionView:
            guard trips.count != 1 else { return }
            if indexPath.row == 0 {
                guard let trip = cheapestTrip else { return }
                let departmentTime = dateTimeFormatter.getDateTime(format: .hhmmss, from: trip, for: .department)
                let arrivingTime = dateTimeFormatter.getDateTime(format: .hhmmss, from: trip, for: .destination)
                let price = Float(trip.price.amount)
                vc.onCellSelected?(trip, date, numberOfPassengers, departurePlaceName, destinationPlaceName,
                                   departmentTime, arrivingTime, price ?? 0)
                
            } else {
                guard let trip = closestTrip else { return }
                let departmentTime = dateTimeFormatter.getDateTime(format: .hhmmss, from: trip, for: .department)
                let arrivingTime = dateTimeFormatter.getDateTime(format: .hhmmss, from: trip, for: .destination)
                let price = Float(trip.price.amount)
                vc.onCellSelected?(trip, date, numberOfPassengers, departurePlaceName, destinationPlaceName,
                                   departmentTime, arrivingTime, price ?? 0)
            }
            
        case vc.allTipsCollectionView:
            let trip = trips[indexPath.row]
            let departmentTime = dateTimeFormatter.getDateTime(format: .hhmmss, from: trip, for: .department)
            let arrivingTime = dateTimeFormatter.getDateTime(format: .hhmmss, from: trip, for: .destination)
            let price = Float(trip.price.amount)
            vc.onCellSelected?(trip, date, numberOfPassengers, departurePlaceName, destinationPlaceName,
                               departmentTime, arrivingTime, price ?? 0)

            
        case vc.cheapTripsToTopCollectionView:
            let trip = cheapTripsToTop[indexPath.row]
            let departmentTime = dateTimeFormatter.getDateTime(format: .hhmmss, from: trip, for: .department)
            let arrivingTime = dateTimeFormatter.getDateTime(format: .hhmmss, from: trip, for: .destination)
            let price = Float(trip.price.amount)
            vc.onCellSelected?(trip, date, numberOfPassengers, departurePlaceName, destinationPlaceName,
                               departmentTime, arrivingTime, price ?? 0)

            
        case vc.cheapTripsToBottomCollectionView:
            let trip = cheapTripsToBottom[indexPath.row]
            let departmentTime = dateTimeFormatter.getDateTime(format: .hhmmss, from: trip, for: .department)
            let arrivingTime = dateTimeFormatter.getDateTime(format: .hhmmss, from: trip, for: .destination)
            let price = Float(trip.price.amount)
            vc.onCellSelected?(trip, date, numberOfPassengers, departurePlaceName, destinationPlaceName,
                               departmentTime, arrivingTime, price ?? 0)

            
        default: break
        }
    }
    
    deinit {
        Log.i("Deallocation \(self)")
    }
}

//MARK:- CollectionViewDataProvider + DelegateFlowLayout
extension MainTripsCollectionViewDataProvider: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let vc = parentVC as? TripsViewController else { return CGSize() }
        let height = collectionView.frame.size.height * 0.9
        let width = collectionView.frame.size.width * 0.8
        let oneCardWidth = collectionView.frame.size.width * 0.9
        let pageScrollViewCellSize = CGSize(width: vc.pageScrollView.frame.size.width * 0.9,
                                            height: vc.pageScrollSubview.frame.size.height * 0.4)
        
        switch collectionView {
        case vc.recommendationsCollectionView: return trips.count == 1 ?
            CGSize(width: oneCardWidth, height: height) : CGSize(width: width, height: height)
            
        case vc.allTipsCollectionView: return pageScrollViewCellSize
            
        case vc.cheapTripsToTopCollectionView: return pageScrollViewCellSize
            
        case vc.cheapTripsToBottomCollectionView: return pageScrollViewCellSize
            
        default: return CGSize()
        }
    }
}
