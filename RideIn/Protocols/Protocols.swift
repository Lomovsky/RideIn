//
//  LinkCConstructorProtocol.swift
//  RideIn
//
//  Created by Алекс Ломовской on 13.04.2021.
//

import UIKit
import MapKit

//MARK:- RideSearchDelegate
protocol RideSearchDelegate: AnyObject {
    func changePassengersCount(with operation: Operation)
    func getPassengersCount() -> String
    func setCoordinates(with placemark: MKPlacemark, forPlace placeType: PlaceType)
    func setNavigationControllerHidden(to state: Bool, animated: Bool)
}

//MARK: - URLFactory
protocol URLFactory {
    func setCoordinates(coordinates: String, place: PlaceType)
    func setSeats(seats: String)
    func setDate(date: String?)
    func makeURL() -> URL?
}

//MARK:- NetworkManager
protocol NetworkManager {
    func downloadData<DataModel: Codable>(withURL url: URL, decodeBy dataModel: DataModel.Type, completionHandler: @escaping (Result<DataModel, Error>) -> Void)
}

//MARK:- DateTimeReturnable
protocol DateTimeFormatter {
    func getDateTime(format: DateFormat, from trip: Trip?, for placeType: PlaceType) -> String
}

//MARK:- Constrainable
protocol ConstraintFactory {
    func makeConstraint(forAnimationState state: AnimationState, animatingView: AnimatingViews, tableSubviewTopAnchor toView: UIView) -> NSLayoutConstraint
}

//MARK:- ReachabilityCheckable
protocol ReachabilityCheckable {
    static func isConnectedToNetwork() -> Bool
}

//MARK:- TripsDataProvider
protocol TripsDataProvider {
    func downloadDataWith(departureCoordinates: String, destinationCoordinates: String, seats: String, date: String?,
                          completion: @escaping (Result<[Trip], Error>) -> Void)
    func prepareData(trips: [Trip], userLocation: CLLocation, completion: @escaping (_ unsortedTrips: [Trip], _ cheapToTop: [Trip],
                                                                                     _ cheapToBottom: [Trip], _ cheapestTrip: Trip?,
                                                                                     _ closestTrip: Trip?) -> Void) throws
}

//MARK:- DistanceCalculator
protocol DistanceCalculator {
    func compareDistances(first: CLLocationDistance, second: CLLocationDistance) -> Bool
    func getDistanceBetween(userLocation: CLLocation, departurePoint: CLLocation) -> CLLocationDistance

}

//MARK:- MapKitPlacesSearchDataProvider
protocol MapKitPlacesSearchDataProvider {
    static func searchForPlace(with keyWord: String?, inRegion region: MKCoordinateRegion, completion: @escaping ([MKMapItem], _ error: Error?) -> Void)
}

//MARK:- PlacesSearchTableViewDataProvider
protocol PlacesSearchTableViewDataProvider: UITableViewDelegate, UITableViewDataSource {
    var matchingItems: [MKMapItem] { get set }
    var parentVC: UIViewController? { get set }
}

//MARK:- TripsCollectionViewDataProvider
protocol TripsCollectionViewDataProvider: UICollectionViewDelegate, UICollectionViewDataSource {
    var parentVC: UIViewController? { get set }
    var departurePlaceName: String { get set }
    var destinationPlaceName: String { get set}
    var trips: [Trip] { get set }
    var cheapTripsToTop: [Trip] { get set }
    var cheapTripsToBottom: [Trip] { get set }
    var cheapestTrip: Trip? { get set }
    var closestTrip: Trip? { get set }
    var date: String { get set }
    var numberOfPassengers: Int { get set }
    var dateTimeFormatter: DateTimeFormatter { get set }
}

//MARK:- RideSearchTableViewDataProviderDelegate
protocol RideSearchTableViewDataProviderDelegate {
    func didSelectCell(passedData name: String?, coordinates: String)
}

//MARK:- MapTableViewDataProviderDelegate
protocol MapTableViewDataProviderDelegate {
    func didSelectCell(passedData placeMark: MKPlacemark)
}
