//
//  RideSearchVCDataProvider.swift
//  RideIn
//
//  Created by Алекс Ломовской on 07.05.2021.
//

import UIKit
import MapKit

final class RideSearchViewControllerDataProvider: ControllerDataProvidable {
    
    //MARK: Declarations -
    /// The controller that owns this dataProvider
    weak var parentController: UIViewController?
    
    /// Data provider is made for downloading data with user request
    lazy var dataManager = makeDataManager()
    
    /// MapKit data provider  with locationManager to request user location and proceed place search requests
    lazy var mapKitDataProvider = makeMapKitDataProvider()
    
    /// Constraint factory made for simplifying textFields animations
    lazy var constraintFactory = makeConstrainFactory()
    
    /// Data provider, that contains tableView delegate and dataSource
    lazy var tableViewDataProvider = makeTableViewDataProvider()
    
    /// Current user region in which to search locations
    var region = MKCoordinateRegion()
    
    /// Timer for limiting search requests
    var timer: Timer?
    
    /// Departure point location to be selected on mapVC
    var departureCLLocation = CLLocation()
    
    /// Departure point coordinates to be selected on mapVC
    var departureCoordinates = String()
    
    /// Destination point coordinates to be selected on mapVC
    var destinationCoordinates = String()
    
    /// The type we work with (departure or destination) to configure methods and data transferring between ViewControllers
    var placeType: PlaceType?
    
    /// The textField which has been selected
    var chosenTF = UITextField()
    
    /// Properties that displays selection state for textField to prevent multiple animations
    var departureTextFieldTapped = false
    
    var destinationTextFieldTapped = false
    
    /// Property for configuring navigationController isHidden state due to gestureRecognizer
    var shouldNavigationControllerBeHiddenAnimated = (hidden: Bool(), animated: Bool())
    
    /// Current date or the date user chose to send as request parameter
    var date: String? = nil
    
    /// Number of passengers to send as request parameter
    var passengersCount = 1
    
    /// This property is used for configuring the declension of the word "Пассажир" due to number of passengers
    var passengerDeclension: Declensions {
        if passengersCount == 1 {
            return .one
        } else if passengersCount <= 4, passengersCount > 1 {
            return .two
        } else {
            return .more
        }
    }
    
    
    init(parentController: UIViewController) {
        self.parentController = parentController
    }
    
    //MARK: Methods -
    /** - This method asks dataProvider to download data
     - Either presents alertController with some error
     - Or calls prepareDataForTripsVCWith method and passes it ([Trip]) object */
    func search() {
        let vc = parentController as! RideSearchViewController
        vc.configureIndicatorAndButton(indicatorEnabled: true)
        dataManager.downloadDataWith(departureCoordinates: departureCoordinates, destinationCoordinates: destinationCoordinates,
                                     seats: "\(passengersCount)", date: date) { [unowned self] result in
            switch result {
            case .failure(let error):
                switch error {
                case NetworkManagerErrors.noConnection:
                    vc.onAlert?(NSLocalizedString("Alert.noConnection", comment: ""))
                    vc.configureIndicatorAndButton(indicatorEnabled: false)
                    
                case NetworkManagerErrors.badRequest:
                    vc.onAlert?(NSLocalizedString("Alert.wrongDataFormat", comment: ""))
                    vc.configureIndicatorAndButton(indicatorEnabled: false)
                    
                case NetworkManagerErrors.unableToMakeURL:
                    Log.e("Unable to make url")
                    
                default:
                    return
                }
                
            case .success(let trips):
                prepareDataForTripsVCWith(trips: trips)
            }
        }
    }
    
    /// This method is responsible for searching places with the given word
    /// - Parameter word: the keyWord to search
    func searchPlaces(word: String?) {
        let vc = parentController as! RideSearchViewController
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 0.3, repeats: false, block: { [unowned self] _ in
            MainMapKitPlacesSearchManager.searchForPlace(with: word, inRegion: vc.mapView.region) { items, error in
                guard error == nil else { return }
                self.tableViewDataProvider.matchingItems = items.filter { $0.placemark.countryCode == "UA" }
                vc.searchTableView.reloadData()
            }
        })
    }
    
    /// This method calls dataProviders method prepareData and passes its result to showTripsVCWith method
    /// - Parameter trips: trips array to pass to dataProvider
    private func prepareDataForTripsVCWith(trips: [Trip]) {
        let vc = parentController as! RideSearchViewController
        
        do {
            try dataManager.prepareData(trips: trips, userLocation: departureCLLocation,
                                        completion: { [unowned self] unsortedTrips, cheapToTop, cheapToBottom, cheapestTrip, closestTrip in
                                            self.sendPreparedData(trips: trips,
                                                                  cheapToTop: cheapToTop,
                                                                  expensiveToTop: cheapToBottom,
                                                                  cheapestTrip: cheapestTrip,
                                                                  closestTrip: closestTrip) })
        } catch _ as NSError {
            vc.onAlert?(NSLocalizedString("Alert.noTrips", comment: ""))
            vc.configureIndicatorAndButton(indicatorEnabled: false)
        }
    }
    
    
    /// Method is responsible for presenting TripsVC with given data
    /// - Parameters:
    ///   - trips: unsorted base [Trip] array
    ///   - cheapToTop: trips array sorted by price increasing
    ///   - expensiveToTop: trips array sorted by price decreasing
    ///   - cheapestTrip: the cheapest trip
    ///   - closestTrip: the trip whose departure point is the closest to the point that user has selected
    private func sendPreparedData(trips: [Trip], cheapToTop: [Trip], expensiveToTop: [Trip], cheapestTrip: Trip?, closestTrip: Trip?) {
        let vc = parentController as! RideSearchViewController
        let formattedData = PreparedTripsDataModelFromSearchVC(unsortedTrips: trips,
                                                               cheapToTop: cheapToTop,
                                                               expensiveToTop: expensiveToTop,
                                                               closestTrip: closestTrip,
                                                               cheapestTrip: cheapestTrip,
                                                               date: date,
                                                               departurePlaceName: vc.departureTextField.text,
                                                               destinationPlaceName: vc.destinationTextField.text,
                                                               passengersCount: passengersCount,
                                                               delegate: vc)
        vc.onDataPrepared?(formattedData)
        vc.configureIndicatorAndButton(indicatorEnabled: false)
    }
    
    deinit {
        Log.i("deallocating\(self)")
    }
    
}

//MARK: Private extension -
private extension RideSearchViewControllerDataProvider {
    func makeMapKitDataProvider() -> MapKitDataProvider {
        let dataProvider = MainMapKitDataProvider()
        dataProvider.parentVC = parentController
        return dataProvider
    }
    
    func makeDataManager() -> TripsDataManager {
        return MainTripsDataManager()
    }
    
    func makeTableViewDataProvider() -> PlacesSearchTableViewDataProvider {
        return RideSearchTableviewDataProvider()
    }
    
    func makeConstrainFactory() -> MainConstraintFactory {
        let vc = parentController as! RideSearchViewController
        let factory = MainConstraintFactory(view: vc.view, destinationContentSubview: vc.destinationContentSubview,
                                            destinationTextField: vc.destinationTextField, tableViewSubview: vc.tableViewSubview)
        return factory
    }
    
}












