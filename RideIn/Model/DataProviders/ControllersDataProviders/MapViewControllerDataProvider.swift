//
//  MapViewControllerDataProvider.swift
//  RideIn
//
//  Created by Алекс Ломовской on 07.05.2021.
//

import UIKit
import MapKit

final class MapViewControllerDataProvider: ControllerDataProvidable {
  //MARK: Declarations -
  /// The controller that owns this dataProvider
  weak var parentController: UIViewController?
  
  /// Data provider for search tableView
  lazy var tableViewDataProvider = makeTableViewDataProvider()
  
  /// Data provider for map kit delegate methods
  lazy var mapKitDataProvider = makeMapKitDataProvider()
  
  ///The type we work with (departure or destination) to configure methods and data transferring between ViewControllers
  var placeType: PlaceType?
  
  ///Timer for limiting search requests
  var timer: Timer?
  
  /// The state of longTapGestureRecognizer to configure the accessibility for user  to make a placemark
  var gestureRecognizerEnabled = true
  
  ///This property says has user tapped on textField or not to prevent multiple animations
  var textFieldActivated = false
  
  ///The property that configures distance subView displaying
  var distanceSubviewIsHidden = true
  
  ///The state of textField represents the accessibility for user to write in textField or activate it by a tap
  var textFieldActivationObserverEnabled = true
  
  init(parentController: UIViewController) {
    self.parentController = parentController
  }
  
  deinit {
    Log.i("deallocating\(self)")
  }
}

//MARK: Private extension -
private extension MapViewControllerDataProvider {
  func makeTableViewDataProvider() -> PlacesSearchTableViewDataProvider {
    let dataProvider = MapTableViewDataProvider()
    dataProvider.parentVC = parentController
    return dataProvider
  }
  
  func makeMapKitDataProvider() -> MapKitDataProvider {
    let dataProvider = MainMapKitDataProvider()
    dataProvider.parentVC = parentController
    dataProvider.setupLocationManager()
    return dataProvider
  }
}
