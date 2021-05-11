//
//  MainFlowCoordinator.swift
//  RideIn
//
//  Created by Алекс Ломовской on 11.05.2021.
//

import UIKit

protocol Alertable {
    func makeAlert(title: String?, message: String?, style: UIAlertController.Style)
    func makeLocationAlert(title: String?, message: String?, style: UIAlertController.Style)
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
        
        vc.onDataPrepared = { [weak self] preparedData in
            self?.preparedDataFromSearchVC = preparedData
            self?.showTripsVC()
        }
        
        vc.onAlert = { [weak self] message in
            self?.makeAlert(title: NSLocalizedString("Alert.error", comment: ""),
                            message: message,
                            style: .alert)
            
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
        vc.configure(with: preparedDataFromSearchVC)
        
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
        vc.configure(with: preparedDataFromTripsVC)
        
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
            vc.controllerDataProvider.placeType = placeType
            vc.rideSearchDelegate = delegate
            
            vc.onFinish = { [weak self] in
                self?.router.popModule()
            }
            
            vc.onAlert = { [weak self] in
                self?.makeLocationAlert(title: NSLocalizedString("Alert.error", comment: ""),
                                        message: NSLocalizedString( "Alert.locationService", comment: ""),
                                        style: .alert)
                
            }
            
            router.push(vc)
            
        case is SelectedTripViewController:
            vc.coordinator = self
            vc.searchTF.text = selectedTrip?.waypoints.first?.place.address
            vc.controllerDataProvider.mapKitDataProvider.parentVC = vc
            vc.controllerDataProvider.gestureRecognizerEnabled = false
            vc.mapView.showsTraffic = true
            vc.controllerDataProvider.mapKitDataProvider.ignoreLocation = true
            vc.controllerDataProvider.distanceSubviewIsHidden = false
            vc.controllerDataProvider.textFieldActivationObserverEnabled = false
            
            vc.controllerDataProvider.mapKitDataProvider.mapKitDataManager.getLocations(trip: selectedTrip) {
                [weak self] depPlacemark, destPlacemark, distance in
                vc.controllerDataProvider.mapKitDataProvider.distance = distance
                
                switch self?.placeType {
                case .department:
                    vc.controllerDataProvider.mapKitDataProvider.mapKitDataManager.dropPinZoomIn(placemark: destPlacemark, zoom: false)
                    vc.controllerDataProvider.mapKitDataProvider.mapKitDataManager.dropPinZoomIn(placemark: depPlacemark, zoom: true)
                    vc.controllerDataProvider.mapKitDataProvider.mapKitDataManager.showRouteOnMap(pickUpPlacemark: depPlacemark,
                                                                           destinationPlacemark: destPlacemark)
                    
                case .destination:
                    vc.controllerDataProvider.mapKitDataProvider.mapKitDataManager.dropPinZoomIn(placemark: destPlacemark, zoom: true)
                    vc.controllerDataProvider.mapKitDataProvider.mapKitDataManager.dropPinZoomIn(placemark: depPlacemark, zoom: false)
                    vc.controllerDataProvider.mapKitDataProvider.mapKitDataManager.showRouteOnMap(pickUpPlacemark: depPlacemark,
                                                                           destinationPlacemark: destPlacemark)
                    
                default:
                    break
                }
            }
            
            vc.onAlert = { [weak self] in
                self?.makeLocationAlert(title: NSLocalizedString("Alert.error", comment: ""),
                                        message: NSLocalizedString( "Alert.locationService", comment: ""),
                                        style: .alert)
            }
            
            vc.onFinish = { [weak self] in
                self?.router.popModule()
            }
            
            router.push(vc)
            
        default:
            break
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