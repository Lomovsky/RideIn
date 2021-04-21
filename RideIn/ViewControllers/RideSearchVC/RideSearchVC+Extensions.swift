//
//  RideSearchVC+Extensions.swift
//  RideIn
//
//  Created by Алекс Ломовской on 13.04.2021.
//

import UIKit
import MapKit

//MARK:- Helping methods
extension RideSearchViewController {
    
    @objc final func setPassengersCount() {
        let vc = PassengersCountViewController()
        vc.rideSearchDelegate = self
        navigationController?.present(vc, animated: true, completion: nil)
    }
    
    @objc final func search() {
        configureIndicatorAndButton(indicatorState: true)
        urlFactory.setCoordinates(coordinates: fromCoordinates, place: .from)
        urlFactory.setCoordinates(coordinates: toCoordinates, place: .to)
        urlFactory.setSeats(seats: "\(passengersCount)")
        if date != nil { urlFactory.setDate(date: date!) }
        guard let url = urlFactory.makeURL() else { return }
        
        networkManager.fetchRides(withURL: url) { [unowned self] (result) in
            
            switch result {
            case .failure(let error): assertionFailure("\(error)")
                
            case .success(let trips): self.prepareDataForTripsVC(trips: trips)
            }
        }
    }
    
    @objc final func dismissFromTextField() {
        fromTextField.resignFirstResponder()
        checkTextFields()
        dismissAnimation(textField: fromTextField)
    }
    
    @objc final func dismissToTextField() {
        toTextField.resignFirstResponder()
        checkTextFields()
        dismissAnimation(textField: toTextField)
    }
    
    @objc final func showMap() {
        let vc = MapViewController()
        vc.rideSearchDelegate = self
        vc.placeType = placeType
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc final func changeDate(sender: UIDatePicker) {
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
    
    
    
    func configureIndicatorAndButton(indicatorState: Bool) {
        if indicatorState {
            activityIndicator.startAnimating()
            activityIndicator.isHidden = false
            searchButton.isHidden = true
        } else {
            activityIndicator.stopAnimating()
            activityIndicator.isHidden = true
            searchButton.isHidden = false
        }
    }
    
    func setCount() {
        switch passengerDeclension {
        case .one:
            passengersButton.setTitle("\(passengersCount) пассажир", for: .normal)
            
        case .two:
            passengersButton.setTitle("\(passengersCount) пассажира", for: .normal)
            
        default:
            passengersButton.setTitle("\(passengersCount) пассажиров", for: .normal)
        }
    }
    
    private func checkTextFields() {
        guard !(fromTextField.text?.isEmpty ?? true), fromTextField.text != "",
              !(toTextField.text?.isEmpty ?? true), fromTextField.text != "" else {
            searchButton.isHidden = true
            return }
        searchButton.isHidden = false
    }
    
    private func lookForPlaces(withWord word: String?) {
        guard let text = word, text != "" else { return }
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = text
        request.region = mapView.region
        let search = MKLocalSearch(request: request)
        
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false, block: { [unowned self] (_) in
            search.start { response, _ in
                guard let response = response else { return }
                self.matchingItems = response.mapItems
                self.searchTableView.reloadData()
            }
        })
    }
    
    private func getDistance(userLocation: CLLocation, departurePoint: CLLocation) -> CLLocationDistance {
        return userLocation.distance(from: departurePoint)
    }
    
    private func compareDistances(first: CLLocationDistance, second: CLLocationDistance) -> Bool {
        return second.isLess(than: first)
    }
    
    private func prepareDataForTripsVC(trips: [Trip]) {
        
        let cheapToBottom = trips.sorted(by: { Float($0.price.amount) ?? 0 < Float($1.price.amount) ?? 0  })
        let cheapToTop = trips.sorted(by: { Float($0.price.amount) ?? 0 > Float($1.price.amount) ?? 0  })
        let cheapestTrip = cheapToTop.last
        let closestTrip = trips.sorted(by: { (trip1, trip2) -> Bool in
            
            let trip1Coordinates = CLLocation(latitude: trip1.waypoints.first!.place.latitude, longitude: trip1.waypoints.first!.place.longitude)
            let trip2Coordinates = CLLocation(latitude: trip2.waypoints.first!.place.latitude, longitude: trip2.waypoints.first!.place.longitude)
            
            let distance1 = getDistance(userLocation: fromCLLocation, departurePoint: trip1Coordinates)
            let distance2 = getDistance(userLocation: fromCLLocation, departurePoint: trip2Coordinates)
            
            return compareDistances(first: distance1, second: distance2)
        }).first
        
        showTripsVC(trips: trips, cheapToTop: cheapToTop, expensiveToTop: cheapToBottom,
                    cheapestTrip: cheapestTrip!, closestTrip: closestTrip!)
    }
    
    private func showTripsVC(trips: [Trip], cheapToTop: [Trip], expensiveToTop: [Trip], cheapestTrip: Trip, closestTrip: Trip) {
        let vc = TripsViewController()
        if date != nil { vc.date = date!.components(separatedBy: "T").first ?? "" }
        vc.trips = trips
        vc.cheapTripsToBottom = cheapToTop
        vc.cheapTripsToTop = expensiveToTop
        vc.cheapestTrip = cheapestTrip
        vc.closestTrip = closestTrip
        vc.departurePlaceName = fromTextField.text ?? ""
        vc.arrivingPlaceName = toTextField.text ?? ""
        vc.numberOfPassengers = passengersCount
        vc.rideSearchDelegate = self
        
        navigationController?.pushViewController(vc, animated: true)
    }
    
}


//MARK: - TextField Delegate
extension RideSearchViewController: UITextFieldDelegate {
    
    @objc final func textFieldDidChange(_ textField: UITextField) {
        checkTextFields()
        
        switch textField {
        case fromTextField: lookForPlaces(withWord: fromTextField.text)
            
        case toTextField: lookForPlaces(withWord: toTextField.text)
            
        default:
            break
        }
    }
    
    @objc func textFieldHasBeenActivated(textField: UITextField) {
        
        switch textField {
        case fromTextField:
            chosenTF = fromTextField
            if !fromTextFieldTapped {
                fromTextFieldTapped = true
                animate(textField: fromTextField)
            }
            placeType = .from
            
        case toTextField:
            chosenTF = toTextField
            if !toTextFieldTapped {
                toTextFieldTapped = true
                animate(textField: toTextField)
            }
            placeType = .to
            
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
                setCount()
            }
            
        case .decrease:
            if passengersCount > 1 {
                passengersCount -= 1
                setCount()
            }
        }
    }
    
    func getPassengersCount() -> String {
        return "\(passengersCount)"
    }
    
    func setCoordinates(placemark: MKPlacemark, forPlace placeType: PlaceType) {
        guard let longitude = placemark.location?.coordinate.longitude,
              let latitude = placemark.location?.coordinate.latitude else { return }
        
        switch placeType {
        case .from:
            fromCoordinates = "\(latitude),\(longitude)"
            fromCLLocation = CLLocation(latitude: latitude, longitude: longitude)
            
        case .to:
            toCoordinates = "\(latitude),\(longitude)"
        }
    }
    
    func continueAfterMapVC(from placeType: PlaceType, withPlaceName name: String) {
        switch placeType {
        
        case .from:
            fromTextField.text = name
            dismissFromTextField()
            
        case .to:
            toTextField.text = name
            dismissToTextField()
        }
    }
    
    func setNavigationControllerHidden(to state: Bool, animated: Bool) {
        navigationController?.setNavigationBarHidden(state, animated: animated)
    }
    
}



//MARK:- TableViewDataSource & Delegate
extension RideSearchViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return matchingItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: RideSearchTableViewCell.reuseIdentifier, for: indexPath) as! RideSearchTableViewCell
        let place = matchingItems[indexPath.row].placemark
        
        print(matchingItems.count)
        cell.textLabel?.font = .boldSystemFont(ofSize: 20)
        cell.textLabel?.numberOfLines = 0
        cell.textLabel?.textColor = .darkGray
        cell.textLabel?.text = place.name
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let placemark = matchingItems[indexPath.row].placemark
        let latitude = placemark.coordinate.latitude
        let longitude = placemark.coordinate.longitude
        let coordinates = "\(latitude),\(longitude)"
        
        switch placeType {
        case .from:
            fromTextField.text = placemark.name
            fromCoordinates = coordinates
            dismissFromTextField()
            
        case .to:
            toTextField.text = placemark.name
            toCoordinates = coordinates
            dismissToTextField()
            
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
        print("error is \(error)")
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
        let constraintFactory: Constraintable = ConstraintFactory(view: view, toContentSubview: toContentSubview, toTextField: toTextField,
                                                                  tableViewSubview: tableViewSubview)
        
        switch textField {
        
        case fromTextField:
            view.setNeedsLayout()
            tableViewSubviewTopConstraint.isActive = false
            
            tableViewSubviewTopConstraint = constraintFactory.makeConstraint(forAnimationState: .animated, animatingView: .tableViewSubview, tableSubviewTopAnchor: fromContentSubview)
            
            tableViewSubviewTopConstraint.isActive = true
            
            UIView.animate(withDuration: 0.3) {
                self.navigationController?.setNavigationBarHidden(true, animated: true)
                self.tableViewSubview.alpha = 1.0
                self.view.layoutIfNeeded()
            }
            setUIElementsHidden(to: true)
            fromBackButton.isHidden = false
            toContentSubview.isHidden = true
            
        case toTextField:
            view.setNeedsLayout()
            toContentSubviewTopConstraint.isActive = false
            tableViewSubviewTopConstraint.isActive = false
            toTFTopConstraint.isActive = false
            
            toContentSubviewTopConstraint = constraintFactory.makeConstraint(forAnimationState: .animated, animatingView: .toContentSubview, tableSubviewTopAnchor: toContentSubview)
            tableViewSubviewTopConstraint = constraintFactory.makeConstraint(forAnimationState: .animated, animatingView: .tableViewSubview, tableSubviewTopAnchor: fromContentSubview)
            toTFTopConstraint = constraintFactory.makeConstraint(forAnimationState: .animated, animatingView: .toTextField, tableSubviewTopAnchor: fromContentSubview)
            
            toContentSubviewTopConstraint.isActive = true
            tableViewSubviewTopConstraint.isActive = true
            toTFTopConstraint.isActive = true
            
            UIView.animate(withDuration: 0.3, delay: 0, options: [.curveEaseOut], animations: {
                self.navigationController?.setNavigationBarHidden(true, animated: true)
                self.tableViewSubview.alpha = 1.0
                self.view.layoutIfNeeded()
            })
            setUIElementsHidden(to: true)
            fromContentSubview.isHidden = true
            toBackButton.isHidden = false
            
        default:
            break
        }
    }
    
    func dismissAnimation(textField: UITextField) {
        let constraintFactory: Constraintable = ConstraintFactory(view: view, toContentSubview: toContentSubview, toTextField: toTextField,
                                                                  tableViewSubview: tableViewSubview)
        
        switch textField {
        case fromTextField:
            fromTextFieldTapped = false
            UIView.animate(withDuration: 0.3) {
                self.navigationController?.setNavigationBarHidden(false, animated: true)
                self.tableViewSubview.alpha = 0.0
                self.view.layoutIfNeeded()
            }
            setUIElementsHidden(to: false)
            fromBackButton.isHidden = true
            toContentSubview.isHidden = false
            
        case toTextField:
            toTextFieldTapped = false
            view.setNeedsLayout()
            toContentSubviewTopConstraint.isActive = false
            toTFTopConstraint.isActive = false
            
            toContentSubviewTopConstraint = constraintFactory.makeConstraint(forAnimationState: .dismissed, animatingView: .toContentSubview, tableSubviewTopAnchor: toContentSubview)
            toTFTopConstraint = constraintFactory.makeConstraint(forAnimationState: .dismissed, animatingView: .toTextField, tableSubviewTopAnchor: toContentSubview)
            
            toContentSubviewTopConstraint.isActive = true
            toTFTopConstraint.isActive = true
            
            UIView.animate(withDuration: 0.3, delay: 0, options: [.curveEaseOut], animations: {
                self.navigationController?.setNavigationBarHidden(false, animated: true)
                self.tableViewSubview.alpha = 0.0
                self.view.layoutIfNeeded()
            })
            setUIElementsHidden(to: false)
            fromContentSubview.isHidden = false
            toBackButton.isHidden = true
            print(toTextField.frame)
            
            
        default:
            break
        }
    }
}





