//
//  RideSearchVC+Extensions.swift
//  RideIn
//
//  Created by Алекс Ломовской on 13.04.2021.
//

import UIKit
import MapKit

//MARK:- Targets&Actions
extension RideSearchViewController {
    
    @objc final func passengersCountButtonTapped() {
        onChoosePassengersCountSelected?(self)
    }
    
    /// - This method asks dataProvider to download data
    /// - Either presents alertController with some error
    /// - Or calls prepareDataForTripsVCWith method and passes it ([Trip]) object
    @objc final func searchButtonTapped() {
        configureIndicatorAndButton(indicatorEnabled: true)
        dataManager.downloadDataWith(departureCoordinates: departureCoordinates,
                                     destinationCoordinates: destinationCoordinates,
                                     seats: "\(passengersCount)", date: date) { [unowned self] result in
            switch result {
            case .failure(let error):
                switch error {
                case NetworkManagerErrors.noConnection:
                    onAlert?(NSLocalizedString("Alert.noConnection", comment: ""))
                    self.configureIndicatorAndButton(indicatorEnabled: false)
                    
                case NetworkManagerErrors.badRequest:
                    onAlert?(NSLocalizedString("Alert.wrongDataFormat", comment: ""))
                    self.configureIndicatorAndButton(indicatorEnabled: false)
                    
                case NetworkManagerErrors.unableToMakeURL:
                    Log.e("Unable to make url")
                    
                default:
                    return
                }
            case .success(let trips): prepareDataForTripsVCWith(trips: trips)
            }
        }
    }
    
    /// Is triggered when the user press back button on departureTF
    @objc func dismissDepartureTextField() {
        departureTextField.resignFirstResponder()
        checkTextFieldsForEmptiness()
        dismissAnimation(textField: departureTextField)
    }
    
    /// Is triggered when the user press back button on destinationTF
    @objc final func dismissDestinationTextField() {
        destinationTextField.resignFirstResponder()
        checkTextFieldsForEmptiness()
        dismissAnimation(textField: destinationTextField)
    }
    
    ///This method configures and pushes MapViewController
    @objc final func showMapButtonTapped() {
        onMapSelected?(placeType, self)
        shouldNavigationControllerBeHiddenAnimated = (true, false)
    }
    
    /// This method changes date property with the new date from UIDatePicker
    /// - Parameter sender: The sender of type UIDatePicker from which we get new date
    @objc final func changeDateWith(sender: UIDatePicker) {
        date = dateTimeFormatter.getDateFrom(datePicker: sender)
    }
}

//MARK:- Helping methods
extension RideSearchViewController {
    
    /// This method is used for configuring "searchButton" and activity indicator state.
    /// Triggered then user press "searchButton" to start activity indicator and hide button to
    /// show user that search has begun.
    /// - Parameter enabled: the state according to which we configure button and activity indicator
    func configureIndicatorAndButton(indicatorEnabled enabled: Bool) {
        if enabled {
            activityIndicator.startAnimating()
            activityIndicator.isHidden = false
            searchButton.isHidden = true
        } else {
            activityIndicator.stopAnimating()
            activityIndicator.isHidden = true
            searchButton.isHidden = false
        }
    }
    
    ///This method configures passengersButton with given number of passengers according to declension
    func setPassengersCountWithDeclension() {
        switch passengerDeclension {
        case .one:
            passengersButton.setTitle("\(passengersCount)" + " " + NSLocalizedString("Search.onePassenger", comment: ""), for: .normal)
            
        case .two:
            passengersButton.setTitle("\(passengersCount)" + " " + NSLocalizedString("Search.lessThanFourPassengers", comment: ""), for: .normal)
            
        default:
            passengersButton.setTitle("\(passengersCount)" + " " + NSLocalizedString("Search.morePassengers", comment: ""), for: .normal)
        }
    }
    
    /// This method is responsible for searching for places in users region
    /// - Parameter word: the keyword of the search (e.g. city name)
    private func searchPlaces(withWord word: String?) {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 0.3, repeats: false, block: { [unowned self] _ in
            MainMapKitPlacesSearchManager.searchForPlace(with: word, inRegion: self.mapView.region) { items, error in
                guard error == nil else { return }
                tableViewDataProvider.matchingItems = items
                self.searchTableView.reloadData()
            }
        })
    }
    
    /// This method calls dataProviders method prepareData and passes its result to showTripsVCWith method
    /// - Parameter trips: trips array to pass to dataProvider
    private func prepareDataForTripsVCWith(trips: [Trip]) {
        do {
            try dataManager.prepareData(trips: trips, userLocation: departureCLLocation,
                                        completion: { [unowned self] unsortedTrips, cheapToTop, cheapToBottom, cheapestTrip, closestTrip in
                                            self.showTripsVCWith(trips: trips,
                                                                 cheapToTop: cheapToTop,
                                                                 expensiveToTop: cheapToBottom,
                                                                 cheapestTrip: cheapestTrip,
                                                                 closestTrip: closestTrip) })
        } catch _ as NSError {
            onAlert?(NSLocalizedString("Alert.noTrips", comment: ""))
            self.configureIndicatorAndButton(indicatorEnabled: false)
            
        }
        
    }
    
    /// Method is responsible for presenting TripsVC with given data
    /// - Parameters:
    ///   - trips: unsorted base [Trip] array
    ///   - cheapToTop: trips array sorted by price increasing
    ///   - expensiveToTop: trips array sorted by price decreasing
    ///   - cheapestTrip: the cheapest trip
    ///   - closestTrip: the trip whose departure point is the closest to the point that user has selected
    private func showTripsVCWith(trips: [Trip], cheapToTop: [Trip], expensiveToTop: [Trip], cheapestTrip: Trip?, closestTrip: Trip?) {
        onSearchButtonSelected?(trips, cheapToTop, expensiveToTop, cheapestTrip,
                                closestTrip, date, departureTextField.text,
                                destinationTextField.text, passengersCount, self)
        configureIndicatorAndButton(indicatorEnabled: false)
    }
}


//MARK: - TextField Delegate
extension RideSearchViewController: UITextFieldDelegate {
    
    /// This method is called each time the user types a character into textField
    /// Calls "checkTextFieldsForEmptiness" function to configure "searchButton" displaying
    /// Calls methods to search places
    /// - Parameter textField: the text field from which calls this method (AKA sender)
    @objc final func textFieldDidChange(_ textField: UITextField) {
        checkTextFieldsForEmptiness()
        
        switch textField {
        case departureTextField: searchPlaces(withWord: departureTextField.text)
            
        case destinationTextField: searchPlaces(withWord: destinationTextField.text)
            
        default: break
        }
    }
    
    /// This method is called each time user tap on a textField
    /// Sets chosenTF & placeType properties respectively to chosen textField
    /// - Parameter textField: the text field from which calls this method (AKA sender)
    @objc func textFieldHasBeenActivated(textField: UITextField) {
        
        switch textField {
        case departureTextField:
            chosenTF = departureTextField
            if !departureTextFieldTapped {
                departureTextFieldTapped = true
                animate(textField: departureTextField)
            }
            placeType = .department
            
        case destinationTextField:
            chosenTF = destinationTextField
            if !destinationTextFieldTapped {
                destinationTextFieldTapped = true
                animate(textField: destinationTextField)
            }
            placeType = .destination
            
        default: break
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    /// This methods checks textField for emptiness to configure "searchButton"s state
    private func checkTextFieldsForEmptiness() {
        guard !(departureTextField.text?.isEmpty ?? true), departureTextField.text != "",
              !(destinationTextField.text?.isEmpty ?? true), departureTextField.text != "" else {
            searchButton.isHidden = true
            return }
        searchButton.isHidden = false
    }
}

//MARK: - RideSearchDelegate
extension RideSearchViewController: RideSearchDelegate {
    
    /// This method of RideSearchDelegate is responsible for changing passengersCount property respectively to given operation type
    /// - Parameter operation: the operation type of type Operation
    func changePassengersCount(with operation: Operation) {
        switch operation {
        case .increase: if passengersCount < 10 { passengersCount += 1 }
            
        case .decrease: if passengersCount > 1 { passengersCount -= 1 }
        }
        setPassengersCountWithDeclension()
    }
    
    /// This method is used for getting passengers count from passengersCount property
    /// - Returns: passengers count of type String
    func getPassengersCount() -> String {
        return "\(passengersCount)"
    }
    
    /// Sets coordinates and place name with a given placemark for specific placeType
    /// - Parameters:
    ///   - placemark: the placemark pinned on mapVC or any other MKMapView
    ///   - placeType: the placeType for which the data is set
    func setCoordinates(with placemark: MKPlacemark, forPlace placeType: PlaceType) {
        guard let longitude = placemark.location?.coordinate.longitude,
              let latitude = placemark.location?.coordinate.latitude else { return }
        
        switch placeType {
        case .department:
            departureCoordinates = "\(latitude),\(longitude)"
            departureCLLocation = CLLocation(latitude: latitude, longitude: longitude)
            departureTextField.text = placemark.name
            dismissDepartureTextField()
            
        case .destination:
            destinationCoordinates = "\(latitude),\(longitude)"
            destinationTextField.text = placemark.name
            dismissDestinationTextField()
        }
    }
    
    /// This method is responsible for configuring navigationController either hidden or not with given parameters
    /// - Parameters:
    ///   - state: similar to isHidden
    ///   - animated: animated or not
    func setNavigationControllerHidden(to state: Bool, animated: Bool) {
        navigationController?.setNavigationBarHidden(state, animated: animated)
    }
    
}

//MARK:- CLLocationManagerDelegate
extension RideSearchViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        guard status == .authorizedWhenInUse else { return }
        mapKitDataProvider.locationManager.requestLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }
        let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        let region = MKCoordinateRegion(center: location.coordinate, span: span)
        mapView.setRegion(region, animated: false)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        Log.e("LocationManager error is \(error)")
    }
    
}


//MARK:- Animations
extension RideSearchViewController {
    
    
    /// This method is user for configuring isHidden property of UIElements with given state
    /// - Parameter state: the state to set
    func setUIElementsHidden(to state: Bool) {
        dateView.isHidden = state
        bottomLine.isHidden = state
        topLine.isHidden = state
        passengersButton.isHidden = state
        tableViewSubview.isHidden = !state
    }
    
    
    /// This method is responsible for animating UITextField and its subview
    /// Calls constraint factory to create new constraints with given parameters
    /// - Parameter textField: the textField which calls this method (AKA sender)
    func animate(textField: UITextField) {
        
        switch textField {
        case departureTextField:
            view.setNeedsLayout()
            tableViewSubviewTopConstraint.isActive = false
            tableViewSubviewTopConstraint = constraintFactory.makeConstraint(forAnimationState: .animated, animatingView: .tableViewSubview, tableSubviewTopAnchor: departureContentSubview)
            tableViewSubviewTopConstraint.isActive = true
            
            UIView.animate(withDuration: 0.3) {
                self.navigationController?.setNavigationBarHidden(true, animated: true)
                self.tableViewSubview.alpha = 1.0
                self.view.layoutIfNeeded()
            }
            setUIElementsHidden(to: true)
            departureBackButton.isHidden = false
            destinationContentSubview.isHidden = true
            
        case destinationTextField:
            view.setNeedsLayout()
            destinationContentSubviewTopConstraint.isActive = false
            tableViewSubviewTopConstraint.isActive = false
            destinationTFTopConstraint.isActive = false
            
            destinationContentSubviewTopConstraint = constraintFactory.makeConstraint(forAnimationState: .animated, animatingView: .toContentSubview, tableSubviewTopAnchor: destinationContentSubview)
            tableViewSubviewTopConstraint = constraintFactory.makeConstraint(forAnimationState: .animated, animatingView: .tableViewSubview, tableSubviewTopAnchor: departureContentSubview)
            destinationTFTopConstraint = constraintFactory.makeConstraint(forAnimationState: .animated, animatingView: .toTextField, tableSubviewTopAnchor: departureContentSubview)
            
            destinationContentSubviewTopConstraint.isActive = true
            tableViewSubviewTopConstraint.isActive = true
            destinationTFTopConstraint.isActive = true
            
            UIView.animate(withDuration: 0.3, delay: 0, options: [.curveEaseOut], animations: {
                self.navigationController?.setNavigationBarHidden(true, animated: true)
                self.tableViewSubview.alpha = 1.0
                self.view.layoutIfNeeded()
            })
            setUIElementsHidden(to: true)
            departureContentSubview.isHidden = true
            destinationBackButton.isHidden = false
            
        default:
            break
        }
    }
    
    /// This method is responsible for dismissing animations of UITextField and its subview
    /// Calls constraint factory to create new constraints with given parameters
    /// - Parameter textField: the textField which calls this method (AKA sender)
    func dismissAnimation(textField: UITextField) {
        switch textField {
        case departureTextField:
            departureTextFieldTapped = false
            UIView.animate(withDuration: 0.3) {
                self.navigationController?.setNavigationBarHidden(false, animated: true)
                self.tableViewSubview.alpha = 0.0
                self.view.layoutIfNeeded()
            }
            setUIElementsHidden(to: false)
            departureBackButton.isHidden = true
            destinationContentSubview.isHidden = false
            
        case destinationTextField:
            destinationTextFieldTapped = false
            view.setNeedsLayout()
            destinationContentSubviewTopConstraint.isActive = false
            destinationTFTopConstraint.isActive = false
            
            destinationContentSubviewTopConstraint = constraintFactory.makeConstraint(forAnimationState: .dismissed, animatingView: .toContentSubview, tableSubviewTopAnchor: destinationContentSubview)
            destinationTFTopConstraint = constraintFactory.makeConstraint(forAnimationState: .dismissed, animatingView: .toTextField, tableSubviewTopAnchor: destinationContentSubview)
            
            destinationContentSubviewTopConstraint.isActive = true
            destinationTFTopConstraint.isActive = true
            
            UIView.animate(withDuration: 0.3, delay: 0, options: [.curveEaseOut], animations: {
                self.navigationController?.setNavigationBarHidden(false, animated: true)
                self.tableViewSubview.alpha = 0.0
                self.view.layoutIfNeeded()
            })
            setUIElementsHidden(to: false)
            departureContentSubview.isHidden = false
            destinationBackButton.isHidden = true
            print(destinationTextField.frame)
            
            
        default:
            break
        }
    }
}





