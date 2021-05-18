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

protocol MainFlowCoordinatorOutput: AnyObject {
  var onFinishFlow: CompletionBlock? { get set }
}

//MARK:- MainFlowCoordinator
final class MainFlowCoordinator: BaseCoordinator, MainFlowCoordinatorOutput {
  var deepLinkOptions: DeepLinkOptions?
  var onFinishFlow: CompletionBlock?
  private weak var navigationController: UINavigationController?
  private var preparedDataFromSearchVC = PreparedTripsDataModelFromSearchVC()
  private var preparedDataFromTripsVC = PreparedTripsDataModelFromTripsVC()
  private var placeType: PlaceType?
  private var delegate: RideSearchDelegate?
  private var selectedTrip: Trip?
  
  //MARK: init-
  init(navigationController: UINavigationController, deepLinkOptions: DeepLinkOptions? = nil) {
    super.init(router: Router(rootController: navigationController))
    self.navigationController = navigationController
    self.deepLinkOptions = deepLinkOptions
  }
  
  override func start() {
    showMainScreen()
  }
  
  func start(withOptions options: DeepLinkOptions) {
    switch options {
    case .notification(let notification):
      switch notification {
      case .newRidesAvailable:
        showMainScreen(shouldBeSelected: true)
      }
    }
  }
  
  //MARK: RideSearchVC -
  private func showMainScreen(shouldBeSelected: Bool = false) {
    let vc = RideSearchViewController()
    vc.shouldBecomeResponderOnLoad = shouldBeSelected
    
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
      self?.makeAlert(title: NSLocalizedString(.Localization.Alert.error, comment: ""),
                      message: message,
                      style: .alert)
    }
    
    vc.onFinish = { [weak self] in
      self?.onFinishFlow?()
    }
    
    router.setRootModule(vc, animated: true)
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
      vc.controllerDataProvider.placeType = placeType
      vc.rideSearchDelegate = delegate
      
      vc.onFinish = { [weak self] in
        self?.router.popModule()
      }
      
      vc.onAlert = { [weak self] in
        self?.makeLocationAlert(title: NSLocalizedString(.Localization.Alert.error, comment: ""),
                                message: NSLocalizedString(.Localization.Alert.locationService, comment: ""),
                                style: .alert)
      }
      router.push(vc)
      
    case is SelectedTripViewController:
      let dataManager =  vc.controllerDataProvider.mapKitDataProvider.mapKitDataManager
      let dataProvider = vc.controllerDataProvider
      
      vc.searchTF.text = selectedTrip?.waypoints.first?.place.address
      vc.mapView.showsTraffic = true
      dataProvider.mapKitDataProvider.parentVC = vc
      dataProvider.gestureRecognizerEnabled = false
      dataProvider.mapKitDataProvider.ignoreLocation = true
      dataProvider.distanceSubviewIsHidden = false
      dataProvider.textFieldActivationObserverEnabled = false
      
      dataProvider.mapKitDataProvider.mapKitDataManager.getLocations(trip: selectedTrip) {
        [weak self] depPlacemark, destPlacemark, distance in
        dataProvider.mapKitDataProvider.distance = distance
        switch self?.placeType {
        case .department:
          dataManager.dropPinZoomIn(placemark: destPlacemark, zoom: false)
          dataManager.dropPinZoomIn(placemark: depPlacemark, zoom: true)
          dataManager.showRouteOnMap(pickUpPlacemark: depPlacemark, destinationPlacemark: destPlacemark)
          
        case .destination:
          dataManager.dropPinZoomIn(placemark: destPlacemark, zoom: true)
          dataManager.dropPinZoomIn(placemark: depPlacemark, zoom: false)
          dataManager.showRouteOnMap(pickUpPlacemark: depPlacemark, destinationPlacemark: destPlacemark)
          
        default:
          break
        }
      }
      
      vc.onAlert = { [weak self] in
        self?.makeLocationAlert(title: NSLocalizedString(.Localization.Alert.error, comment: ""),
                                message: NSLocalizedString(.Localization.Alert.locationService, comment: ""),
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
  
  deinit {
    Log.i("Deallocating \(self)")
  }
}
