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
    
    func setupLongTapRecognizer() {
        if gestureRecognizerEnabled {
            let longTapGesture = UILongPressGestureRecognizer(target: self, action: #selector(longTap))
            mapView.addGestureRecognizer(longTapGesture)
        }
    }
    
    @objc final func goBack() {
        navigationController?.popViewController(animated: true)
    }
    

    @objc final func sendCoordinatesToRideSearchVC() {
        guard let placemark = selectedPin, let placeName = searchTF.text else { return }
        
        switch placeType {
        case .department:
            rideSearchDelegate?.setCoordinates(with: placemark, forPlace:.department)
            rideSearchDelegate?.continueAfterMapVC(from: .department, withPlaceName: placeName)
            navigationController?.popToRootViewController(animated: true)
            
        case .destination:
            rideSearchDelegate?.setCoordinates(with: placemark, forPlace: .destination)
            rideSearchDelegate?.continueAfterMapVC(from: .destination, withPlaceName: placeName)
            navigationController?.popToRootViewController(animated: true)
            
            
        default:
            break
        }
    }
    
    @objc private func dismissTableView() {
        animateTableView(toSelected: false)
        searchTF.resignFirstResponder()
        backButton.removeTarget(self, action: #selector(dismissTableView), for: .touchUpInside)
        backButton.addTarget(self, action: #selector(goBack), for: .touchUpInside)
    }
    
    
    @objc private func longTap(sender: UIGestureRecognizer){
        print("long tap")
        if sender.state == .began {
            mapView.removeAnnotations(mapView.annotations)
            let locationInView = sender.location(in: mapView)
            let locationOnMap = mapView.convert(locationInView, toCoordinateFrom: mapView)
            addAnnotation(location: locationOnMap)
        }
    }

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
        
        cell.textLabel?.text = place.name
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

