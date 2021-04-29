//
//  DataProviders.swift
//  RideIn
//
//  Created by Алекс Ломовской on 28.04.2021.
//

import UIKit
import MapKit

//MARK: - MainTripsDataProvider
final class MainTripsDataProvider: TripsDataProvider {
    
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

//MARK:- MainMapKitPlacesSearchDataProvider
struct MainMapKitPlacesSearchDataProvider: MapKitPlacesSearchDataProvider {
    
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

//MARK:- RideSearchTableviewDataProvider
final class RideSearchTableviewDataProvider: NSObject, PlacesSearchTableViewDataProvider {
    
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
        print(matchingItems.count)
        cell.textLabel?.font = .boldSystemFont(ofSize: 20)
        cell.textLabel?.numberOfLines = 0
        cell.textLabel?.textColor = .darkGray
        if let country = place.country, let administrativeArea = place.administrativeArea, let name = place.name {
            cell.textLabel?.text = "\(country), \(administrativeArea), \(name)"
        } else {
            cell.textLabel?.text = place.name
        }
        cell.detailTextLabel?.text = MainMapKitPlacesSearchDataProvider.parseAddress(selectedItem: place)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let vc = parentVC as? RideSearchViewController else { return }
        tableView.deselectRow(at: indexPath, animated: true)
        let placemark = matchingItems[indexPath.row].placemark
        let latitude = placemark.coordinate.latitude
        let longitude = placemark.coordinate.longitude
        let coordinates = "\(latitude),\(longitude)"
        
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
    
    ///The array of items that match to users search
    var matchingItems = [MKMapItem]()
    
    /// Parent viewController that asks for data
    var parentVC: UIViewController?
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return matchingItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: MapTableViewCell.reuseIdentifier, for: indexPath) as! MapTableViewCell
        let place = matchingItems[indexPath.row].placemark
        guard let country = place.country,
              let administrativeArea = place.administrativeArea,
              let name = place.name else { return UITableViewCell()}
        
        cell.textLabel?.text = ("\(country), \(administrativeArea), \(name)")
        cell.detailTextLabel?.text = MainMapKitPlacesSearchDataProvider.parseAddress(selectedItem: place)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let vc = parentVC as? MapViewController else { return }
        let place = matchingItems[indexPath.row].placemark
        vc.mapView.removeAnnotations(vc.mapView.annotations)
        vc.dropPinZoomIn(placemark: place, zoom: true)
        vc.dismissTableView()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let vc = parentVC as? MapViewController else { return 0.0 }
        return vc.searchTF.frame.height
    }
    
}

//MARK:- MainTripsCollectionViewDataProvider
final class MainTripsCollectionViewDataProvider: NSObject, TripsCollectionViewDataProvider {
    
    /// Parent viewController that asks for data
    var parentVC: UIViewController?
    
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
                vc.showTripVC(trip: trip, date: date, passengersCount: numberOfPassengers, departmentPlace: departurePlaceName,
                              departmentTime: departmentTime, arrivingPlace: destinationPlaceName,
                              arrivingTime: arrivingTime, price: price ?? 0)
            } else {
                guard let trip = closestTrip else { return }
                let departmentTime = dateTimeFormatter.getDateTime(format: .hhmmss, from: trip, for: .department)
                let arrivingTime = dateTimeFormatter.getDateTime(format: .hhmmss, from: trip, for: .destination)
                let price = Float(trip.price.amount)
                vc.showTripVC(trip: trip, date: date, passengersCount: numberOfPassengers, departmentPlace: departurePlaceName,
                              departmentTime: departmentTime, arrivingPlace: destinationPlaceName,
                              arrivingTime: arrivingTime, price: price ?? 0)
            }
            
        case vc.allTipsCollectionView:
            let trip = trips[indexPath.row]
            let departmentTime = dateTimeFormatter.getDateTime(format: .hhmmss, from: trip, for: .department)
            let arrivingTime = dateTimeFormatter.getDateTime(format: .hhmmss, from: trip, for: .destination)
            let price = Float(trip.price.amount)
            vc.showTripVC(trip: trip, date: date, passengersCount: numberOfPassengers, departmentPlace: departurePlaceName,
                          departmentTime: departmentTime, arrivingPlace: destinationPlaceName,
                          arrivingTime: arrivingTime, price: price ?? 0)
            
        case vc.cheapTripsToTopCollectionView:
            let trip = cheapTripsToTop[indexPath.row]
            let departmentTime = dateTimeFormatter.getDateTime(format: .hhmmss, from: trip, for: .department)
            let arrivingTime = dateTimeFormatter.getDateTime(format: .hhmmss, from: trip, for: .destination)
            let price = Float(trip.price.amount)
            vc.showTripVC(trip: trip, date: date, passengersCount: numberOfPassengers, departmentPlace: departurePlaceName,
                          departmentTime: departmentTime, arrivingPlace: destinationPlaceName,
                          arrivingTime: arrivingTime, price: price ?? 0)
            
        case vc.cheapTripsToBottomCollectionView:
            let trip = cheapTripsToBottom[indexPath.row]
            let departmentTime = dateTimeFormatter.getDateTime(format: .hhmmss, from: trip, for: .department)
            let arrivingTime = dateTimeFormatter.getDateTime(format: .hhmmss, from: trip, for: .destination)
            let price = Float(trip.price.amount)
            vc.showTripVC(trip: trip, date: date, passengersCount: numberOfPassengers, departmentPlace: departurePlaceName,
                          departmentTime: departmentTime, arrivingPlace: destinationPlaceName,
                          arrivingTime: arrivingTime, price: price ?? 0)
            
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
