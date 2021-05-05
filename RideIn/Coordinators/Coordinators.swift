//
//  Coordinators.swift
//  RideIn
//
//  Created by Алекс Ломовской on 05.05.2021.
//

import UIKit
import MapKit

//MARK: - BaseCoordinator
class BaseCoordinator: Coordinator {
    var childCoordinators = [Coordinator]()
    var router: Router
    
    init(router: Router) {
        self.router = router
    }
    
    func start() {}
    
    func getNavController() -> UINavigationController {
        return UINavigationController()
        
    }
}

//MARK:- MainFlowCoordinator
final class MainFlowCoordinator: BaseCoordinator {
    
    /// Either departure or destination to operate data and pass between controllers
    private var placeType: PlaceType?
    
    /// RideSearchDelegate
    private var delegate: RideSearchDelegate?
    
    /// NavigationController that manages View hierarchy
    private weak var navigationController: UINavigationController?
    
    /// The name of the departure place
    private var departurePlaceName = String()
    
    /// The name of destination place
    private var destinationPlaceName = String()
    
    /// The base unsorted array of available trips
    private var trips = [Trip]()
    
    /// The sorted array of available trips with increasing price
    private var cheapTripsToTop = [Trip]()
    
    /// The sorted array of available trips with decreasing price
    private var cheapTripsToBottom = [Trip]()
    
    /// The cheapest trip
    private var cheapestTrip: Trip?
    
    /// The closest to user departure  point trip
    private var closestTrip: Trip?
    
    /// Number of passengers
    private var numberOfPassengers = Int()
    
    /// The selected trip departure date
    private var date = String ()
    
    
    /// Time of the departure
    private var departureTime = String()
    
    /// The time user will arrive
    private var arrivingTime = String()
    
    /// Price of the trip for 1 person
    private var price = Float()
    
    /// The trip that user selected on TripsVC
    private var selectedTrip: Trip?
    
    //MARK: init-
    init(navigationController: UINavigationController) {
        super.init(router: Router(rootController: navigationController))
        self.navigationController = navigationController
    }
    
    override func start() {
        showMainScreen()
    }
    
    override func getNavController() -> UINavigationController {
        return navigationController!
    }
    
    //MARK: rideSearchVC -
    private func showMainScreen() {
        let vc = RideSearchViewController()
        vc.coordinator = self
        
        vc.onMapSelected = { [weak self] placeType, delegate in
            self?.placeType = placeType
            self?.delegate = delegate
            self?.showMap(from: vc)
        }
        
        vc.onChoosePassengersCountSelected = { [weak self] delegate in
            self?.delegate = delegate
            self?.showPassengersCountVC()
        }
        
        vc.onSearchButtonSelected = { [weak self] trips, cheapToTop, expensiveToTop, cheapestTrip, closestTrip, date, departurePlaceName, destinationPlaceName, passengersCount, delegate  in
            self?.trips = trips
            self?.cheapTripsToTop = cheapToTop
            self?.cheapTripsToBottom = expensiveToTop
            self?.cheapestTrip = cheapestTrip
            self?.closestTrip = closestTrip
            self?.date = date ?? NSLocalizedString("Date", comment: "")
            self?.departurePlaceName = departurePlaceName!
            self?.destinationPlaceName = destinationPlaceName!
            self?.numberOfPassengers = passengersCount
            self?.delegate = delegate
            self?.showTripsVC()
        }
        
        router.setRootModule(vc)
    }
    
    
    //MARK: passengersCountVC -
    private func showPassengersCountVC() {
        let vc = PassengersCountViewController()
        vc.rideSearchDelegate = delegate
        router.present(vc)
    }
    
    //MARK: tripsVC -
    private func showTripsVC() {
        let vc = TripsViewController()
        vc.coordinator = self
        vc.dataProvider.trips = trips
        vc.dataProvider.cheapTripsToTop = cheapTripsToTop
        vc.dataProvider.cheapTripsToBottom = cheapTripsToBottom
        vc.dataProvider.cheapestTrip = cheapestTrip
        vc.dataProvider.closestTrip = closestTrip
        vc.dataProvider.date = date
        vc.dataProvider.departurePlaceName = departurePlaceName
        vc.dataProvider.destinationPlaceName = destinationPlaceName
        vc.dataProvider.numberOfPassengers = numberOfPassengers
        vc.rideSearchDelegate = delegate
        
        vc.onFinish = { [weak self] in
            self?.router.popModule()
        }
        
        vc.onCellSelected = { [weak self] trip, date, passengersCount, departurePlaceName, destinationPlaceName,
                                          departureTime, arrivingTime, price in
            self?.selectedTrip = trip
            self?.date = date
            self?.numberOfPassengers = passengersCount
            self?.departurePlaceName = departurePlaceName
            self?.destinationPlaceName = destinationPlaceName
            self?.departureTime = departureTime
            self?.arrivingTime = arrivingTime
            self?.price = price
            self?.numberOfPassengers = passengersCount
            self?.showSelectedTripVC()
        }
        
        router.push(vc)
    }
    
    //MARK: selectedTripVC -
    private func showSelectedTripVC() {
        let vc = SelectedTripViewController()
        vc.coordinator = self
        vc.date = date
        vc.arrivingTime = arrivingTime
        vc.departurePlace = departurePlaceName
        vc.destinationPlace = destinationPlaceName
        vc.departureTime = departureTime
        vc.passengersCount = numberOfPassengers
        vc.priceForOne = price
        vc.selectedTrip = selectedTrip
        
        vc.onMapSelected = { [weak self] placeType, selectedTrip in
            self?.selectedTrip = selectedTrip
            self?.placeType = placeType
            self?.showMap(from: vc)
        }
        
        vc.onFinish = { [weak self] in
            self?.router.popModule()
        }
        
        router.push(vc)
    }
    
    
    //MARK: mapVC -
    private func showMap(from controller: UIViewController) {
        switch controller {
        case is RideSearchViewController:
            let vc = MapViewController()
            vc.coordinator = self
            vc.placeType = placeType
            vc.rideSearchDelegate = delegate
            
            vc.onFinish = { [weak self] in
                self?.router.popModule()
            }
            
            router.push(vc)
            
        case is SelectedTripViewController:
            let vc = MapViewController()
            vc.coordinator = self
            vc.searchTF.text = selectedTrip?.waypoints.first?.place.address
            vc.mapKitDataProvider.parentVC = vc
            vc.gestureRecognizerEnabled = false
            vc.mapView.showsTraffic = true
            vc.mapKitDataProvider.ignoreLocation = true
            vc.distanceSubviewIsHidden = false
            vc.textFieldActivationObserverEnabled = false
            
            vc.mapKitDataProvider.mapKitDataManager.getLocations(trip: selectedTrip) { [weak self] depPlacemark, destPlacemark, distance in
                vc.mapKitDataProvider.distance = distance
                
                switch self?.placeType {
                case .department:
                    vc.mapKitDataProvider.mapKitDataManager.dropPinZoomIn(placemark: destPlacemark, zoom: false)
                    vc.mapKitDataProvider.mapKitDataManager.dropPinZoomIn(placemark: depPlacemark, zoom: true)
                    vc.mapKitDataProvider.mapKitDataManager.showRouteOnMap(pickUpPlacemark: depPlacemark, destinationPlacemark: destPlacemark)
                    
                case .destination:
                    vc.mapKitDataProvider.mapKitDataManager.dropPinZoomIn(placemark: destPlacemark, zoom: true)
                    vc.mapKitDataProvider.mapKitDataManager.dropPinZoomIn(placemark: depPlacemark, zoom: false)
                    vc.mapKitDataProvider.mapKitDataManager.showRouteOnMap(pickUpPlacemark: depPlacemark, destinationPlacemark: destPlacemark)
                    
                default:
                    break
                }
            }
            
            vc.onFinish = { [weak self] in
                self?.router.popModule()
            }
            
            router.push(vc)
            
        default: break
        }
        
    }
    
}

