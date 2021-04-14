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
    
    @objc final func textFieldDidChange(_ textField: UITextField) {
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
                self.placesTableView.reloadData()
            }
        })
    }

    
    @objc func textFieldHasBeenActivated(textField: UITextField) {
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
    
    @objc final func goBack() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc final func dismissTableView() {
        animateTableView(toSelected: false)
        searchTF.resignFirstResponder()
        backButton.removeTarget(self, action: #selector(dismissTableView), for: .touchUpInside)
        backButton.addTarget(self, action: #selector(goBack), for: .touchUpInside)
    }
    
    @objc final func sendCoordinates() {
        guard let placemark = selectedPin else { return }
        
        switch placeType {
        case .from:
            rideSearchDelegate?.setCoordinates(placemark: placemark, forPlace: .from)
            navigationController?.popToRootViewController(animated: true)
            
        case .to:
            rideSearchDelegate?.setCoordinates(placemark: placemark, forPlace: .to)
            navigationController?.popToRootViewController(animated: true)

            
        default:
            break
        }
    }
    
    func animateTableView(toSelected state: Bool) {
        if state {
            textFieldTapped = true
            placesTableView.isHidden = false
            
            UIView.animate(withDuration: 0.3) {
                self.placesTableView.alpha = 1.0
            }
        } else {
            textFieldTapped = false
            UIView.animate(withDuration: 0.3) {
                self.placesTableView.alpha = 0.0
            }
            placesTableView.isHidden = true
            
        }
    }
    
    
    func parseAddress(selectedItem: MKPlacemark) -> String {
        // put a space between "4" and "Melrose Place"
        let firstSpace = (selectedItem.subThoroughfare != nil && selectedItem.thoroughfare != nil) ? " " : ""
        // put a comma between street and city/state
        let comma = (selectedItem.subThoroughfare != nil || selectedItem.thoroughfare != nil) && (selectedItem.subAdministrativeArea != nil || selectedItem.administrativeArea != nil) ? ", " : ""
        // put a space between "Washington" and "DC"
        let secondSpace = (selectedItem.subAdministrativeArea != nil && selectedItem.administrativeArea != nil) ? " " : ""
        let addressLine = String(
            format:"%@%@%@%@%@%@%@",
            // street number
            selectedItem.subThoroughfare ?? "",
            firstSpace,
            // street name
            selectedItem.thoroughfare ?? "",
            comma,
            // city
            selectedItem.locality ?? "",
            secondSpace,
            // state
            selectedItem.administrativeArea ?? ""
        )
        return addressLine
    }
    
}


//MARK:- CLLocationManagerDelegate
extension MapViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            locationManager.requestLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
            let region = MKCoordinateRegion(center: location.coordinate, span: span)
            mapView.setRegion(region, animated: true)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("error is \(error)")
    }
    
   
    
}

//MARK:- MKMapViewDelegate
extension MapViewController: MKMapViewDelegate {
    
}


//MARK:- TableViewDataSource & Delegate
extension MapViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return matchingItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: MapTableViewCell.reuseIdentifier, for: indexPath) as! MapTableViewCell
        
        let place = matchingItems[indexPath.row].placemark
    
        cell.textLabel?.text = place.name
        cell.detailTextLabel?.isHidden = false
        cell.detailTextLabel?.text = parseAddress(selectedItem: place)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let place = matchingItems[indexPath.row].placemark
        dropPinZoomIn(placemark: place)
        dismissTableView()
        
    }
    
}

extension MapViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return searchTF.frame.height
    }
}

//MARK:- HandleMapSearch
extension MapViewController: HandleMapSearch {
    
    func dropPinZoomIn(placemark: MKPlacemark){
        // cache the pin
        selectedPin = placemark
        // clear existing pins
        mapView.removeAnnotations(mapView.annotations)
        let annotation = MKPointAnnotation()
        annotation.coordinate = placemark.coordinate
        annotation.title = placemark.name
        if let city = placemark.locality,
        let state = placemark.administrativeArea {
            annotation.subtitle = "\(city) \(state)"
        }
        mapView.addAnnotation(annotation)
        let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        let region = MKCoordinateRegion(center: placemark.coordinate, span: span)
        mapView.setRegion(region, animated: true)
    }
}
