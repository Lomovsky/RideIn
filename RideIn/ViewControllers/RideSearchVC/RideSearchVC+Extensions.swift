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
        urlFactory.setCoordinates(coordinates: fromCoordinates, place: .from)
        urlFactory.setCoordinates(coordinates: toCoordinates, place: .to)
        guard let url = urlFactory.makeURL() else { return }
        print(url)
        networkManager.fetchRides(withURL: url)
    }
    
    @objc func dismissFromTextField() {
        fromTextField.resignFirstResponder()
        dismissAnimation(textField: fromTextField)
    }
    
    @objc func dismissToTextField() {
        toTextField.resignFirstResponder()
        dismissAnimation(textField: toTextField)
    }
    
    @objc final func showMap() {
        let vc = MapViewController()
        vc.rideSearchDelegate = self
        vc.placeType = placeType
        navigationController?.pushViewController(vc, animated: true)
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
    
    //MARK: Animation methods
    func setHidden(to state: Bool) {
        dateButton.isHidden = state
        searchButton.isHidden = state
        bottomLine.isHidden = state
        topLine.isHidden = state
        passengersButton.isHidden = state
        tableViewSubview.isHidden = !state
    }
    
    func animate(textField: UITextField) {
        
        switch textField {
        case fromTextField:
            view.setNeedsLayout()
            UIView.animate(withDuration: 0.3) {
                self.navigationController?.setNavigationBarHidden(true, animated: true)
                self.tableViewSubviewTopConstraint.isActive = false
                self.tableViewSubviewTopConstraint.isActive = false
                self.tableViewSubviewTopConstraint = NSLayoutConstraint(item: self.tableViewSubview,
                                                                        attribute: .top,
                                                                        relatedBy: .equal,
                                                                        toItem: self.fromContentSubview,
                                                                        attribute: .bottom,
                                                                        multiplier: 1,
                                                                        constant: 0)
                self.tableViewSubviewTopConstraint.isActive = true
                self.tableViewSubviewTopConstraint.isActive = true
                self.tableViewSubview.alpha = 1.0
                self.view.layoutIfNeeded()
            }
            setHidden(to: true)
            fromBackButton.isHidden = false
            toContentSubview.isHidden = true
            
        case toTextField:
            tableViewSubview.topAnchor.constraint(equalTo: fromTextField.bottomAnchor).isActive = false
            tableViewSubview.topAnchor.constraint(equalTo: toTextField.bottomAnchor).isActive = true
            view.setNeedsLayout()
            UIView.animate(withDuration: 0.3, delay: 0, options: [.curveEaseOut], animations: {
                self.toContentSubviewTopConstraint.isActive = false
                self.toTFTopConstraint.isActive = false
                self.tableViewSubviewTopConstraint.isActive = false
                
                self.navigationController?.setNavigationBarHidden(true, animated: true)
                self.toContentSubviewTopConstraint = NSLayoutConstraint(item: self.toContentSubview,
                                                                        attribute: .top,
                                                                        relatedBy: .equal,
                                                                        toItem: self.view.safeAreaLayoutGuide,
                                                                        attribute: .top,
                                                                        multiplier: 1,
                                                                        constant: 30)
                self.toTFTopConstraint = NSLayoutConstraint(item: self.toTextField,
                                                            attribute: .top,
                                                            relatedBy: .equal,
                                                            toItem: self.view.safeAreaLayoutGuide,
                                                            attribute: .top,
                                                            multiplier: 1,
                                                            constant: 30)
                self.tableViewSubviewTopConstraint = NSLayoutConstraint(item: self.tableViewSubview,
                                                                        attribute: .top,
                                                                        relatedBy: .equal,
                                                                        toItem: self.toContentSubview,
                                                                        attribute: .bottom,
                                                                        multiplier: 1,
                                                                        constant: 0)
                self.toContentSubviewTopConstraint.isActive = true
                self.toTFTopConstraint.isActive = true
                self.tableViewSubviewTopConstraint.isActive = true
                self.tableViewSubview.alpha = 1.0
                self.view.layoutIfNeeded()
            })
            setHidden(to: true)
            fromContentSubview.isHidden = true
            toBackButton.isHidden = false
            print(toTextField.frame)
            
        default:
            break
        }
    }
    
    func dismissAnimation(textField: UITextField) {
        
        switch textField {
        case fromTextField:
            fromTextFieldTapped = false
            UIView.animate(withDuration: 0.3) {
                self.navigationController?.setNavigationBarHidden(false, animated: true)
                self.tableViewSubview.alpha = 0.0
                self.view.layoutIfNeeded()
            }
            
            setHidden(to: false)
            fromBackButton.isHidden = true
            toContentSubview.isHidden = false
            print("\(fromTextField.frame) fromTF")
            
        case toTextField:
            toTextFieldTapped = false
            view.setNeedsLayout()
            UIView.animate(withDuration: 0.3, delay: 0, options: [.curveEaseOut], animations: {
                self.navigationController?.setNavigationBarHidden(false, animated: true)
                self.toContentSubviewTopConstraint.isActive = false
                self.toTFTopConstraint.isActive = false
                self.toContentSubviewTopConstraint = NSLayoutConstraint(item: self.toContentSubview,
                                                                        attribute: .top,
                                                                        relatedBy: .equal,
                                                                        toItem: self.view.safeAreaLayoutGuide,
                                                                        attribute: .top,
                                                                        multiplier: 1,
                                                                        constant: 45 + (self.view.frame.height * 0.07))
                self.toTFTopConstraint = NSLayoutConstraint(item: self.toTextField,
                                                            attribute: .top,
                                                            relatedBy: .equal,
                                                            toItem: self.view.safeAreaLayoutGuide,
                                                            attribute: .top,
                                                            multiplier: 1,
                                                            constant: 45 + (self.view.frame.height * 0.07))
                self.toContentSubviewTopConstraint.isActive = true
                self.toTFTopConstraint.isActive = true
                self.tableViewSubview.alpha = 0.0
                self.view.layoutIfNeeded()
            })
            setHidden(to: false)
            fromContentSubview.isHidden = false
            toBackButton.isHidden = true
            print(toTextField.frame)
            
            
        default:
            break
        }
    }
}




//MARK: - TextField Delegate

extension RideSearchViewController: UITextFieldDelegate {
    
    @objc final func textFieldDidChange(_ textField: UITextField) {
        switch textField {
        case fromTextField:
            guard let text = textField.text, text != "" else { return }
            let request = MKLocalSearch.Request()
            request.naturalLanguageQuery = text
            request.region = mapView.region
            let search = MKLocalSearch(request: request)
            
            timer?.invalidate()
            timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: false, block: { [unowned self] (_) in
                search.start { response, _ in
                    guard let response = response else {
                        return
                    }
                    self.matchingItems = response.mapItems
                    self.searchTableView.reloadData()
                }
            })
            
        case toTextField:
            guard let text = textField.text, text != "" else { return }
            let request = MKLocalSearch.Request()
            request.naturalLanguageQuery = text
            request.region = mapView.region
            let search = MKLocalSearch(request: request)
            
            timer?.invalidate()
            timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: false, block: { [unowned self] (_) in
                search.start { response, _ in
                    guard let response = response else {
                        return
                    }
                    self.matchingItems = response.mapItems
                    self.searchTableView.reloadData()
                }
            })
            
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
