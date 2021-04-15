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
    
    func showMap(withPlaceType placeType: PlaceType) {
        let vc = MapViewController()
        vc.rideSearchDelegate = self
        vc.placeType = placeType
        navigationController?.pushViewController(vc, animated: true)
    }
    
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
                                                                        toItem: self.fromTextField,
                                                                        attribute: .bottom,
                                                                        multiplier: 1,
                                                                        constant: 0)
                self.tableViewSubviewTopConstraint = NSLayoutConstraint(item: self.tableViewSubview,
                                                                        attribute: .top,
                                                                        relatedBy: .equal,
                                                                        toItem: self.fromTextField,
                                                                        attribute: .bottom,
                                                                        multiplier: 1,
                                                                        constant: 0)
                self.tableViewSubviewTopConstraint.isActive = true
                self.tableViewSubviewTopConstraint.isActive = true
                self.tableViewSubview.alpha = 1.0
                self.view.layoutIfNeeded()
            }
            setHidden(to: true)
            toTextField.isHidden = true
            
        case toTextField:
            tableViewSubview.topAnchor.constraint(equalTo: fromTextField.bottomAnchor).isActive = false
            tableViewSubview.topAnchor.constraint(equalTo: toTextField.bottomAnchor).isActive = true
            view.setNeedsLayout()
            UIView.animate(withDuration: 0.3, delay: 0, options: [.curveEaseOut], animations: {
                self.toTFTopConstraint.isActive = false
                self.tableViewSubviewTopConstraint.isActive = false
                self.navigationController?.setNavigationBarHidden(true, animated: true)
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
                                                                        toItem: self.toTextField,
                                                                        attribute: .bottom,
                                                                        multiplier: 1,
                                                                        constant: 0)
                self.toTFTopConstraint.isActive = true
                self.tableViewSubviewTopConstraint.isActive = true
                self.tableViewSubview.alpha = 1.0
                self.view.layoutIfNeeded()
            })
            setHidden(to: true)
            fromTextField.isHidden = true
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
            toTextField.isHidden = false
            print("\(fromTextField.frame) fromTF")
            
        case toTextField:
            toTextFieldTapped = false
            view.setNeedsLayout()
            UIView.animate(withDuration: 0.3, delay: 0, options: [.curveEaseOut], animations: {
                self.navigationController?.setNavigationBarHidden(false, animated: true)
                self.toTFTopConstraint.isActive = false
                self.toTFTopConstraint = NSLayoutConstraint(item: self.toTextField,
                                                            attribute: .top,
                                                            relatedBy: .equal,
                                                            toItem: self.view.safeAreaLayoutGuide,
                                                            attribute: .top,
                                                            multiplier: 1,
                                                            constant: 45 + (self.view.frame.height * 0.07))
                self.toTFTopConstraint.isActive = true
                self.tableViewSubview.alpha = 0.0
                self.view.layoutIfNeeded()
            })
            setHidden(to: false)
            fromTextField.isHidden = false
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
            
        case toTextField:
            chosenTF = toTextField
            if !toTextFieldTapped {
                toTextFieldTapped = true
                animate(textField: toTextField)
            }
            
        default:
            break
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case fromTextField:
            fromTextField.resignFirstResponder()
            dismissAnimation(textField: textField)
            return true
            
        case toTextField:
            toTextField.resignFirstResponder()
            dismissAnimation(textField: textField)
            return true
            
        default:
            return false
        }
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
            fromCoordinates = "\(longitude),\(latitude)"
            
        case .to:
            toCoordinates = "\(longitude),\(latitude)"
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
        
        if indexPath.row == 0 {
            switch chosenTF {
            case fromTextField:
                showMap(withPlaceType: .from)
                
            case toTextField:
                showMap(withPlaceType: .to)

            default:
                break
            }
        } else {
            print("TODO: PICK A PLACE")
        }
    }
}

extension RideSearchViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return (view.frame.height * 0.07)
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
