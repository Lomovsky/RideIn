//
//  LinkCConstructorProtocol.swift
//  RideIn
//
//  Created by Алекс Ломовской on 13.04.2021.
//

import UIKit
import MapKit

//MARK:- VCDelegate protocols
protocol RideSearchDelegate: AnyObject {
    func changePassengersCount(with operation: Operation)
    func getPassengersCount() -> String
    func setCoordinates(with placemark: MKPlacemark, forPlace placeType: PlaceType)
    func setNavigationControllerHidden(to state: Bool, animated: Bool)
}


//MARK:- Network protocols
protocol ReachabilityCheckable {
    static func isConnectedToNetwork() -> Bool
}

protocol NetworkManager {
    func downloadData<DataModel: Codable>(withURL url: URL, decodeBy dataModel: DataModel.Type,
                                          completionHandler: @escaping (Result<DataModel, Error>) -> Void)
}


//MARK:- Helpers protocols
protocol DistanceCalculator {
    func compareDistances(first: CLLocationDistance, second: CLLocationDistance) -> Bool
    func getDistanceBetween(userLocation: CLLocation, departurePoint: CLLocation) -> CLLocationDistance
}

protocol DateTimeFormatter {
    func getDateTime(format: DateFormat, from trip: Trip?, for placeType: PlaceType) -> String
    func getDateFrom(datePicker: UIDatePicker) -> String
}

protocol HandleMapSearch {
    func dropPinZoomIn(placemark: MKPlacemark, zoom: Bool)
}

protocol Alertable {
    func makeAlert(title: String?, message: String?, style: UIAlertController.Style)
    func makeLocationAlert(title: String?, message: String?, style: UIAlertController.Style)
}

protocol DetailedCellModel {
    associatedtype T
    func update(with object1: T?, object2: T?)
}

protocol ReusableView: AnyObject {
    static var defaultReuseIdentifier: String { get }
}

extension ReusableView where Self: UIView {
    static var defaultReuseIdentifier: String {
        return NSStringFromClass(self)
    }
}

protocol ControllerConfigurable {
    associatedtype Object
    func configure(with object: Object)
}

//MARK:- Factories
protocol URLFactory {
    func setCoordinates(coordinates: String, place: PlaceType)
    func setSeats(seats: String)
    func setDate(date: String?)
    func makeURL() -> URL?
}

protocol ConstraintFactory {
    func makeConstraint(forAnimationState state: AnimationState, animatingView: AnimatingViews,
                        tableSubviewTopAnchor toView: UIView) -> NSLayoutConstraint
}

protocol ControllerDataProvidersFactory {
    static func makeProvider(for viewController: UIViewController) -> ControllerDataProvidable?
}

//MARK:- DataManagers protocols
protocol MapKitPlacesSearchManager {
    static func searchForPlace(with keyWord: String?, inRegion region: MKCoordinateRegion,
                               completion: @escaping ([MKMapItem], _ error: Error?) -> Void)
}

protocol TripsDataManager {
    func downloadDataWith(departureCoordinates: String, destinationCoordinates: String, seats: String, date: String?,
                          completion: @escaping (Result<[Trip], Error>) -> Void)
    func prepareData(trips: [Trip], userLocation: CLLocation, completion: @escaping (_ unsortedTrips: [Trip], _ cheapToTop: [Trip],
                                                                                     _ cheapToBottom: [Trip], _ cheapestTrip: Trip?,
                                                                                     _ closestTrip: Trip?) -> Void) throws
}

protocol MapKitDataManager: HandleMapSearch {
    var parentDataProvider: MapKitDataProvider? { get set }
    func addAnnotation(location: CLLocationCoordinate2D)
    func lookUpForLocation(by coordinates: CLLocation?, completionHandler: @escaping (CLPlacemark?) -> Void )
    func showRouteOnMap(pickUpPlacemark: MKPlacemark, destinationPlacemark: MKPlacemark)
    func getLocations(trip: Trip?, completion: @escaping (MKPlacemark, MKPlacemark, Int) -> Void)
}


//MARK: - DataProviders&Delegates

protocol ControllerDataProvidable: AnyObject {
    var parentController: UIViewController? { get set }
}



protocol PlacesSearchTableViewDataProvider: UITableViewDelegate, UITableViewDataSource {
    var matchingItems: [MKMapItem] { get set }
    var parentVC: UIViewController? { get set }
}

protocol RideSearchTableViewDataProviderDelegate {
    func didSelectCell(passedData name: String?, coordinates: String)
}

protocol MapTableViewDataProviderDelegate {
    func didSelectCell(passedData placeMark: MKPlacemark)
}

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
}

protocol MainTripsCollectionViewDataProviderDelegate {
    func didSelectItemAt()
}

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


//MARK:- CoordinatorProtocol
protocol Coordinator: AnyObject {
    var childCoordinators: [Coordinator] { get set }
    var router: Router { get }
    func start()
    func addDependency(coordinator: Coordinator)
    func removeDependency(coordinator: Coordinator)
    func getNavController() -> UINavigationController
}

extension Coordinator {
    
    func addDependency(coordinator: Coordinator) {
        for element in childCoordinators {
            if element === coordinator { return }
        }
        childCoordinators.append(coordinator)
    }
    
    func removeDependency(coordinator: Coordinator) {
        guard !(childCoordinators.isEmpty) else { return }
        for (index, element) in childCoordinators.enumerated() {
            if element === coordinator {
                childCoordinators.remove(at: index)
                break
            }
        }
    }
}


//MARK:- Router
protocol Presentable {
    func toPresent() -> UIViewController?
}

protocol Routable: Presentable {
    func present(_ module: Presentable?)
    func present(_ module: Presentable?, animated: Bool)
    func present(_ module: Presentable?, animated: Bool, completion: CompletionBlock?)
    
    func push(_ module: Presentable?)
    func push(_ module: Presentable?, animated: Bool)
    func push(_ module: Presentable?, animated: Bool, completion: CompletionBlock?)
    
    func popModule()
    func popModule(animated: Bool)
    
    func dismissModule()
    func dismissModule(animated: Bool, completion: CompletionBlock?)
    
    func setRootModule(_ module: Presentable?)
    func setRootModule(_ module: Presentable?, hideBar: Bool)
    
    func popToRootModule(animated: Bool)
}


