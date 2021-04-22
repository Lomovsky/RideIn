//
//  RideSearchVC+Extensions.swift
//  RideIn
//
//  Created by Алекс Ломовской on 13.04.2021.
//

import UIKit
import MapKit

//MARK:- UIGestureRecognizerDelegate
extension RideSearchViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                           shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    

}

//MARK:- Helping methods
extension RideSearchViewController {
    
    @objc final func setPassengersCount() {
        let vc = PassengersCountViewController()
        vc.rideSearchDelegate = self
        navigationController?.present(vc, animated: true, completion: nil)
    }
    
    @objc final func searchButtonTapped() {
        configureIndicatorAndButton(indicatorEnabled: true)
        urlFactory.setCoordinates(coordinates: departureCoordinates, place: .department)
        urlFactory.setCoordinates(coordinates: destinationCoordinates, place: .destination)
        urlFactory.setSeats(seats: "\(passengersCount)")
        if date != nil { urlFactory.setDate(date: date!) }
        guard let url = urlFactory.makeURL() else { return }
        
        networkManager.fetchRides(withURL: url) { [unowned self] (result) in
            
            switch result {
            case .failure(let error): assertionFailure("\(error)")
                
            case .success(let trips): self.prepareDataForTripsVCWith(trips: trips)
            }
        }
    }
    
    @objc final func dismissDepartureTextField() {
        departureTextField.resignFirstResponder()
        checkTextFieldsForEmptiness()
        dismissAnimation(textField: departureTextField)
    }
    
    @objc final func dismissDestinationTextField() {
        destinationTextField.resignFirstResponder()
        checkTextFieldsForEmptiness()
        dismissAnimation(textField: destinationTextField)
    }
    
    @objc final func showMapButtonTapped() {
        let vc = MapViewController()
        vc.rideSearchDelegate = self
        vc.placeType = placeType
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc final func changeDateWith(sender: UIDatePicker) {
        guard let day = Calendar.current.dateComponents([.day], from: datePicker.date).day,
              let month = Calendar.current.dateComponents([.month], from: datePicker.date).month,
              let year = Calendar.current.dateComponents([.year], from: datePicker.date).year
        else { return }
        
        let yearString = "\(String(describing: year))"
        var dayString = "\(String(describing: day))"
        var monthString = "\(String(describing: month))"
        
        if day < 10 { dayString = "0\(String(describing: day))" }
        if month < 10 { monthString = "0\(String(describing: month))" }
        
        date = yearString + "-" + monthString + "-" + dayString + "T00:00:00"
    }
    
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
    
    func setPassengersCountWithDeclension() {
        switch passengerDeclension {
        case .one:
            passengersButton.setTitle("\(passengersCount) пассажир", for: .normal)
            
        case .two:
            passengersButton.setTitle("\(passengersCount) пассажира", for: .normal)
            
        default:
            passengersButton.setTitle("\(passengersCount) пассажиров", for: .normal)
        }
    }
    
    private func checkTextFieldsForEmptiness() {
        guard !(departureTextField.text?.isEmpty ?? true), departureTextField.text != "",
              !(destinationTextField.text?.isEmpty ?? true), departureTextField.text != "" else {
            searchButton.isHidden = true
            return }
        searchButton.isHidden = false
    }
    
    private func searchPlaces(withWord word: String?) {
        guard let text = word, text != "" else { return }
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = text
        request.region = mapView.region
        request.resultTypes = .address
        let search = MKLocalSearch(request: request)
        
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false, block: { [unowned self] (_) in
            search.start { response, _ in
                guard let response = response else { return }
                self.matchingItems = response.mapItems
                print(response.mapItems.count)
                self.searchTableView.reloadData()
            }
        })
    }
    
    private func getDistanceBetween(userLocation: CLLocation, departurePoint: CLLocation) -> CLLocationDistance {
        return userLocation.distance(from: departurePoint)
    }
    
    private func compareDistances(first: CLLocationDistance, second: CLLocationDistance) -> Bool {
        return second.isLess(than: first)
    }
    
    private func prepareDataForTripsVCWith(trips: [Trip]) {
        if !(trips.isEmpty) {
            let cheapToBottom = trips.sorted(by: { Float($0.price.amount) ?? 0 < Float($1.price.amount) ?? 0  })
            let cheapToTop = trips.sorted(by: { Float($0.price.amount) ?? 0 > Float($1.price.amount) ?? 0  })
            let cheapestTrip = cheapToTop.last
            let closestTrip = trips.sorted(by: { (trip1, trip2) -> Bool in
                
                let trip1Coordinates = CLLocation(latitude: trip1.waypoints.first!.place.latitude, longitude: trip1.waypoints.first!.place.longitude)
                let trip2Coordinates = CLLocation(latitude: trip2.waypoints.first!.place.latitude, longitude: trip2.waypoints.first!.place.longitude)
                
                let distance1 = getDistanceBetween(userLocation: departureCLLocation, departurePoint: trip1Coordinates)
                let distance2 = getDistanceBetween(userLocation: departureCLLocation, departurePoint: trip2Coordinates)
                
                return compareDistances(first: distance1, second: distance2)
            }).first
            
            showTripsVCWith(trips: trips, cheapToTop: cheapToTop, expensiveToTop: cheapToBottom,
                            cheapestTrip: cheapestTrip!, closestTrip: closestTrip!)
        } else {
            present(alertController, animated: true)
            configureIndicatorAndButton(indicatorEnabled: false)
        }
        
    }
    
    private func showTripsVCWith(trips: [Trip], cheapToTop: [Trip], expensiveToTop: [Trip], cheapestTrip: Trip, closestTrip: Trip) {
        let vc = TripsViewController()
        if date != nil { vc.date = date!.components(separatedBy: "T").first ?? "" }
        vc.trips = trips
        vc.cheapTripsToBottom = cheapToTop
        vc.cheapTripsToTop = expensiveToTop
        vc.cheapestTrip = cheapestTrip
        vc.closestTrip = closestTrip
        vc.departurePlaceName = departureTextField.text ?? ""
        vc.destinationPlaceName = destinationTextField.text ?? ""
        vc.numberOfPassengers = passengersCount
        vc.rideSearchDelegate = self
        configureIndicatorAndButton(indicatorEnabled: false)
        navigationController?.pushViewController(vc, animated: true)
    }
    
}


//MARK: - TextField Delegate
extension RideSearchViewController: UITextFieldDelegate {
    
    @objc final func textFieldDidChange(_ textField: UITextField) {
        checkTextFieldsForEmptiness()
        
        switch textField {
        case departureTextField: searchPlaces(withWord: departureTextField.text)
            
        case destinationTextField: searchPlaces(withWord: destinationTextField.text)
            
        default:
            break
        }
    }
    
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
            
        default:
            break
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

//MARK: - RideSearchDelegate
extension RideSearchViewController: RideSearchDelegate {
    
    func changePassengersCount(with operation: Operation) {
        switch operation {
        case .increase:
            if passengersCount < 10 {
                passengersCount += 1
                setPassengersCountWithDeclension()
            }
            
        case .decrease:
            if passengersCount > 1 {
                passengersCount -= 1
                setPassengersCountWithDeclension()
            }
        }
    }
    
    func getPassengersCount() -> String {
        return "\(passengersCount)"
    }
    
    func setCoordinates(with placemark: MKPlacemark, forPlace placeType: PlaceType) {
        guard let longitude = placemark.location?.coordinate.longitude,
              let latitude = placemark.location?.coordinate.latitude else { return }
        
        switch placeType {
        case .department:
            departureCoordinates = "\(latitude),\(longitude)"
            departureCLLocation = CLLocation(latitude: latitude, longitude: longitude)
            
        case .destination:
            destinationCoordinates = "\(latitude),\(longitude)"
        }
    }
    
    func continueAfterMapVC(from placeType: PlaceType, withPlaceName name: String) {
        switch placeType {
        
        case .department:
            departureTextField.text = name
            dismissDepartureTextField()
            
        case .destination:
            destinationTextField.text = name
            dismissDestinationTextField()
        }
    }
    
    func setNavigationControllerHidden(to state: Bool, animated: Bool) {
        navigationController?.setNavigationBarHidden(state, animated: animated)
    }
    
}



//MARK:- TableViewDataSource & Delegate
extension RideSearchViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print(matchingItems.count)
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
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let placemark = matchingItems[indexPath.row].placemark
        let latitude = placemark.coordinate.latitude
        let longitude = placemark.coordinate.longitude
        let coordinates = "\(latitude),\(longitude)"

        switch placeType {
        case .department:
            departureTextField.text = placemark.name
            departureCoordinates = coordinates
            dismissDepartureTextField()
            
        case .destination:
            destinationTextField.text = placemark.name
            destinationCoordinates = coordinates
            dismissDestinationTextField()
            
        default:
            break
        }
    }
}

extension RideSearchViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return view.frame.height * 0.07
    }
}



//MARK:- CLLocationManagerDelegate
extension RideSearchViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            locationManager.requestLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
            let region = MKCoordinateRegion(center: location.coordinate, span: span)
            mapView.setRegion(region, animated: false)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("LocationManager error is \(error)")
    }
    
}


//MARK:- Animations
extension RideSearchViewController {
    
    func setUIElementsHidden(to state: Bool) {
        dateView.isHidden = state
        bottomLine.isHidden = state
        topLine.isHidden = state
        passengersButton.isHidden = state
        tableViewSubview.isHidden = !state
    }
    
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





