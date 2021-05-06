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
    
    private weak var navigationController: UINavigationController?
    
    private var preparedDataFromSearchVC = PreparedTripsDataModelFromSearchVC()
    
    private var preparedDataFromTripsVC = PreparedTripsDataModelFromTripsVC()
    
    private var placeType: PlaceType?
    
    private var delegate: RideSearchDelegate?
    
    private var selectedTrip: Trip?
    
    
    //MARK: init-
    init(navigationController: UINavigationController) {
        super.init(router: Router(rootController: navigationController))
        self.navigationController = navigationController
    }
    
    override func start() {
        showMainScreen()
        addDependency(coordinator: self)
    }
    
    override func getNavController() -> UINavigationController {
        return navigationController!
    }
    
    //MARK: RideSearchVC -
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
        
        vc.onSearchButtonSelected = { [weak self] preparedData  in
            self?.preparedDataFromSearchVC = preparedData
            self?.showTripsVC()
        }
        
        vc.onAlert = { [weak self] message in
            self?.makeAlert(title: NSLocalizedString("Alert.error", comment: ""), message: message, style: .alert)
            
        }
        
        router.setRootModule(vc)
    }
    
    
    //MARK: PassengersCountVC -
    private func showPassengersCountVC() {
        let vc = PassengersCountViewController()
        vc.rideSearchDelegate = delegate
        router.present(vc)
    }
    
    //MARK: TripsVC -
    private func showTripsVC() {
        let vc = TripsViewController()
        vc.coordinator = self
        if preparedDataFromSearchVC.date != nil {
            vc.dataProvider.date = preparedDataFromSearchVC.date!
        } else {
            vc.dataProvider.date = NSLocalizedString("Date", comment: "")
        }
        vc.dataProvider.trips = preparedDataFromSearchVC.unsortedTrips
        vc.dataProvider.cheapTripsToTop = preparedDataFromSearchVC.cheapToTop
        vc.dataProvider.cheapTripsToBottom = preparedDataFromSearchVC.expensiveToTop
        vc.dataProvider.cheapestTrip = preparedDataFromSearchVC.cheapestTrip
        vc.dataProvider.closestTrip = preparedDataFromSearchVC.closestTrip
        vc.dataProvider.departurePlaceName = preparedDataFromSearchVC.departurePlaceName!
        vc.dataProvider.destinationPlaceName = preparedDataFromSearchVC.destinationPlaceName!
        vc.dataProvider.numberOfPassengers = preparedDataFromSearchVC.passengersCount
        vc.rideSearchDelegate = delegate
        
        vc.onFinish = { [weak self] in
            self?.router.popModule()
        }
        
        vc.onCellSelected = { [weak self] preparedData in
            self?.preparedDataFromTripsVC = preparedData
            self?.showSelectedTripVC()
        }
        
        router.push(vc)
    }
    
    //MARK: SelectedTripVC -
    private func showSelectedTripVC() {
        let vc = SelectedTripViewController()
        vc.coordinator = self
        vc.date = preparedDataFromTripsVC.date
        vc.arrivingTime = preparedDataFromTripsVC.arrivingTime
        vc.departurePlace = preparedDataFromTripsVC.departurePlace
        vc.destinationPlace = preparedDataFromTripsVC.destinationPlace
        vc.departureTime = preparedDataFromTripsVC.departureTime
        vc.passengersCount = preparedDataFromTripsVC.passengersCount
        vc.priceForOne = preparedDataFromTripsVC.price
        vc.selectedTrip = preparedDataFromTripsVC.selectedTrip
        
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
    
    
    //MARK: MapVC -
    private func showMap(from controller: UIViewController) {
        let vc = MapViewController()
        
        switch controller {
        case is RideSearchViewController:
            vc.coordinator = self
            vc.placeType = placeType
            vc.rideSearchDelegate = delegate
            
            vc.onFinish = { [weak self] in
                self?.router.popModule()
            }
            
            vc.onAlert = { [weak self] in
                self?.makeLocationAlert(title: NSLocalizedString("Alert.error", comment: ""),
                                        message: NSLocalizedString( "Alert.locationService", comment: ""), style: .alert)
                
            }
            
            router.push(vc)
            
        case is SelectedTripViewController:
            vc.coordinator = self
            vc.searchTF.text = selectedTrip?.waypoints.first?.place.address
            vc.mapKitDataProvider.parentVC = vc
            vc.gestureRecognizerEnabled = false
            vc.mapView.showsTraffic = true
            vc.mapKitDataProvider.ignoreLocation = true
            vc.distanceSubviewIsHidden = false
            vc.textFieldActivationObserverEnabled = false
            
            vc.mapKitDataProvider.mapKitDataManager.getLocations(trip: selectedTrip) { [weak self] depPlacemark,
                                                                                                   destPlacemark,
                                                                                                   distance in
                vc.mapKitDataProvider.distance = distance
                
                switch self?.placeType {
                case .department:
                    vc.mapKitDataProvider.mapKitDataManager.dropPinZoomIn(placemark: destPlacemark, zoom: false)
                    vc.mapKitDataProvider.mapKitDataManager.dropPinZoomIn(placemark: depPlacemark, zoom: true)
                    vc.mapKitDataProvider.mapKitDataManager.showRouteOnMap(pickUpPlacemark: depPlacemark,
                                                                           destinationPlacemark: destPlacemark)
                    
                case .destination:
                    vc.mapKitDataProvider.mapKitDataManager.dropPinZoomIn(placemark: destPlacemark, zoom: true)
                    vc.mapKitDataProvider.mapKitDataManager.dropPinZoomIn(placemark: depPlacemark, zoom: false)
                    vc.mapKitDataProvider.mapKitDataManager.showRouteOnMap(pickUpPlacemark: depPlacemark,
                                                                           destinationPlacemark: destPlacemark)
                    
                default:
                    break
                }
            }
            
            vc.onAlert = { [weak self] in
                self?.makeLocationAlert(title: NSLocalizedString("Alert.error", comment: ""),
                                        message: NSLocalizedString( "Alert.locationService", comment: ""), style: .alert)
                
            }
            
            vc.onFinish = { [weak self] in
                self?.router.popModule()
            }
            
            router.push(vc)
            
        default: break
        }
    }
}

extension MainFlowCoordinator: Alertable {
    
    func makeLocationAlert(title: String?, message: String?, style: UIAlertController.Style) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: style)
        let goToSettingsButton = UIAlertAction(title: NSLocalizedString("Alert.openSettings", comment: ""), style: .default) { _ in
            guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else { return }
            guard UIApplication.shared.canOpenURL(settingsUrl) else { return }
            UIApplication.shared.open(settingsUrl)
        }
        let dismissButton = UIAlertAction(title: NSLocalizedString("Alert.dismiss", comment: ""), style: .cancel) { [unowned self] _ in
            self.router.popModule()
        }
        alert.addAction(dismissButton)
        alert.addAction(goToSettingsButton)
        router.present(alert, animated: true)
    }
    
    func makeAlert(title: String?, message: String?, style: UIAlertController.Style) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: style)
        let dismissButton = UIAlertAction(title: NSLocalizedString("Alert.dismiss", comment: ""),
                                          style: .cancel) { [unowned self] _ in
            self.router.popModule()
        }
        alert.addAction(dismissButton)
        router.present(alert, animated: true)
    }
    
    
}
