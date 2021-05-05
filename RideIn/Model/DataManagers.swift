//
//  DataManagers.swift
//  RideIn
//
//  Created by Алекс Ломовской on 30.04.2021.
//

import UIKit
import MapKit

//MARK: - MainTripsDataManager
final class MainTripsDataManager: TripsDataManager {
    
    /// This works with URLFactory and network manager to download data with the given coordinates and additional optional data
    /// - Parameters:
    ///   - departureCoordinates: departureCoordinates
    ///   - destinationCoordinates: destinationCoordinates
    ///   - seats: number of seats
    ///   - date: departure date
    ///   - completion: completion handler to process the data
    func downloadDataWith(departureCoordinates: String, destinationCoordinates: String, seats: String, date: String?, completion: @escaping (Result<[Trip], Error>) -> Void)  {
        let urlFactory: URLFactory = MainURLFactory()
        let networkManager: NetworkManager = MainNetworkManager()
        urlFactory.setCoordinates(coordinates: departureCoordinates, place: .department)
        urlFactory.setCoordinates(coordinates: destinationCoordinates, place: .destination)
        urlFactory.setSeats(seats: seats)
        if date != nil { urlFactory.setDate(date: date!) }
        
        guard let url = urlFactory.makeURL() else { let error = NetworkManagerErrors.unableToMakeURL; completion(.failure(error)); return }
        networkManager.downloadData(withURL: url, decodeBy: Trips.self) { (result) in
            switch result {
            case .failure(let error): completion(.failure(error))
                
            case .success(let decodedData): completion(.success(decodedData.trips))
            }
        }
    }
    
    /// This method is responsible for preparing trips array to be presented on TripsVC
    /// - Parameters:
    ///   - trips: unsorted trips array
    ///   - userLocation: users current location or the location the user set on mapView
    ///   - completion: completionHandler to work with prepared data
    /// - Throws: if there will be zero trips in array (e.g. no trips available for some city ), the method will throw an error, which we can use to display warning etc.
    func prepareData(trips: [Trip], userLocation: CLLocation, completion: @escaping (_ unsortedTrips: [Trip], _ cheapToTop: [Trip], _ cheapToBottom: [Trip], _ cheapestTrip: Trip?, _ closestTrip: Trip?) -> Void) throws {
        guard !(trips.isEmpty) else { let error = NetworkManagerErrors.noTrips; throw error }
        let distanceCalculator: DistanceCalculator = MainDistanceCalculator()
        
        let unsortedTrips = trips
        let cheapToBottom = trips.sorted(by: { Float($0.price.amount) ?? 0 > Float($1.price.amount) ?? 0  })
        let cheapToTop = trips.sorted(by: { Float($0.price.amount) ?? 0 < Float($1.price.amount) ?? 0  })
        let cheapestTrip = cheapToTop.first
        let closestTrip = trips.sorted(by: { (trip1, trip2) -> Bool in
            
            let trip1Coordinates = CLLocation(latitude: trip1.waypoints.first!.place.latitude, longitude: trip1.waypoints.first!.place.longitude)
            let trip2Coordinates = CLLocation(latitude: trip2.waypoints.first!.place.latitude, longitude: trip2.waypoints.first!.place.longitude)
            let distance1 = distanceCalculator.getDistanceBetween(userLocation: userLocation, departurePoint: trip1Coordinates)
            let distance2 = distanceCalculator.getDistanceBetween(userLocation: userLocation, departurePoint: trip2Coordinates)
            
            return distanceCalculator.compareDistances(first: distance1, second: distance2)
        }).first
        
        completion(unsortedTrips, cheapToTop, cheapToBottom, cheapestTrip, closestTrip)
    }
    
    deinit {
        Log.i("deallocating \(self)")
    }
}

//MARK:- MainMapKitPlacesSearchManager
struct MainMapKitPlacesSearchManager: MapKitPlacesSearchManager {
    
    /// This method is responsible for searching for locations&places by user request
    /// - Parameters:
    ///   - keyWord: the place name user types
    ///   - region: region in which to search (commonly mapKit region)
    ///   - completion: completion handler to work with data that the method returns
    static func searchForPlace(with keyWord: String?, inRegion region: MKCoordinateRegion,
                               completion: @escaping (_ matchingItems: [MKMapItem], _ error: Error?) -> Void) {
        guard let text = keyWord, text != "" else { return }
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = text
        request.region = region
        request.resultTypes = .address
        let search = MKLocalSearch(request: request)
        search.start { response, error in
            guard let response = response else { return }
            completion(response.mapItems, error)
        }
    }
    
    /// This method is responsible for parsing address to more detailed and user-friendly style
    /// - Parameter selectedItem: the placemark which data will be precessed
    /// - Returns: string address line
    static func parseAddress(selectedItem: MKPlacemark) -> String {
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
    
}

//MARK:- MainMapKitDataManager
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
