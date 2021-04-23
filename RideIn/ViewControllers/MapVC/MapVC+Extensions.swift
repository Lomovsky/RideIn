//
//  MapVC+Extensions.swift
//  RideIn
//
//  Created by Алекс Ломовской on 14.04.2021.
//

import UIKit
import MapKit


//MARK:- UITextFieldDelegate
extension MapViewController: UITextFieldDelegate {
    
    /// This method is called each time the user types a character into textField
    /// Creates search request and starts is every time interval
    /// - Parameter textField: the text field from which calls this method (AKA sender)
    @objc final func textFieldDidChange(_ textField: UITextField) {
        guard let text = textField.text, text != "" else { proceedButton.isHidden = true; return }
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = text
        request.region = mapView.region
        let search = MKLocalSearch(request: request)
        
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false, block: { (_) in
            search.start { [unowned self] response, _ in
                guard let response = response else { proceedButton.isHidden = true; return }
                self.matchingItems = response.mapItems
                self.placesTableView.reloadData()
            }
        })
        proceedButton.isHidden = false
    }
    
    /// This method is called each time user tap on a textField
    /// Sets chosenTF & placeType properties respectively to chosen textField
    /// - Parameter textField: the text field from which calls this method (AKA sender)
    @objc final func textFieldHasBeenActivated(textField: UITextField) {
        animateTableView(toSelected: true)
        backButton.removeTarget(self, action: #selector(goBack), for: .touchUpInside)
        backButton.addTarget(self, action: #selector(dismissTableView), for: .touchUpInside)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        animateTableView(toSelected: false)
        return true
    }
    
}

//MARK: - HelpingMethods
extension MapViewController {
    
    /// This method configures longTapGestureRecognizer and adds is to mapView
    func setupLongTapRecognizer() {
        if gestureRecognizerEnabled {
            let longTapGesture = UILongPressGestureRecognizer(target: self, action: #selector(longTap))
            mapView.addGestureRecognizer(longTapGesture)
        }
    }
    
    /// This method is called when the user press backButton
    @objc final func goBack() {
        navigationController?.popViewController(animated: true)
    }
    
    /// This method is called when the user press "proceedButton"
    /// - Uses rideSearchDelegate method to set coordinates to RideSearchViewController
    /// - Dismisses MapVC
    @objc final func sendCoordinatesToRideSearchVC() {
        guard let placemark = selectedPin else { return }
        
        switch placeType {
        case .department:
            rideSearchDelegate?.setCoordinates(with: placemark, forPlace:.department)
            navigationController?.popToRootViewController(animated: true)
            
        case .destination:
            rideSearchDelegate?.setCoordinates(with: placemark, forPlace: .destination)
            navigationController?.popToRootViewController(animated: true)
            
        default:
            break
        }
    }
    
    /// This method is called when user press "focusOnUserLocationButton"
    /// and what a surprise, this method focus mapView on user location
    @objc final func userLocationButtonTapped() {
        let location = mapView.userLocation
        let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        let region = MKCoordinateRegion(center: location.coordinate, span: span)
        mapView.setRegion(region, animated: true)
    }
    
    /// This method is called when tableView is not hidden and user press back button
    @objc private func dismissTableView() {
        animateTableView(toSelected: false)
        searchTF.resignFirstResponder()
        backButton.removeTarget(self, action: #selector(dismissTableView), for: .touchUpInside)
        backButton.addTarget(self, action: #selector(goBack), for: .touchUpInside)
    }
    
    
    /// The method is called when UIGestureRecognizes longTap
    /// calls "addAnnotation" method to add a placemark
    /// - Parameter sender: the gesture recognizer
    @objc private func longTap(sender: UIGestureRecognizer){
        print("long tap")
        if sender.state == .began {
            mapView.removeAnnotations(mapView.annotations)
            let locationInView = sender.location(in: mapView)
            let locationOnMap = mapView.convert(locationInView, toCoordinateFrom: mapView)
            addAnnotation(location: locationOnMap)
        }
    }

    
    /// This method animates tableView to either hidden or not
    /// - Parameter state: should it be shown or not
    private func animateTableView(toSelected state: Bool) {
        if state {
            textFieldActivated = true
            placesTableView.isHidden = false
            
            UIView.animate(withDuration: 0.3) {
                self.placesTableView.alpha = 1.0
            }
        } else {
            textFieldActivated = false
            UIView.animate(withDuration: 0.3) {
                self.placesTableView.alpha = 0.0
            }
            placesTableView.isHidden = true
        }
    }
    
}

//MARK:- TableViewDataSource & Delegate
extension MapViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return matchingItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: MapTableViewCell.reuseIdentifier, for: indexPath) as! MapTableViewCell
        let place = matchingItems[indexPath.row].placemark
        guard let country = place.country,
              let administrativeArea = place.administrativeArea,
              let name = place.name else { return UITableViewCell()}
        
        cell.textLabel?.text = ("\(country), \(administrativeArea), \(name)")
        cell.detailTextLabel?.isHidden = false
        cell.detailTextLabel?.text = parseAddress(selectedItem: place)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let place = matchingItems[indexPath.row].placemark
        mapView.removeAnnotations(mapView.annotations)
        dropPinZoomIn(placemark: place, zoom: true)
        dismissTableView()
    }
}


extension MapViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return searchTF.frame.height
    }
}

