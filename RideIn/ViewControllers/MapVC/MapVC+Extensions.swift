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
        
        if let text = textField.text, text != "" {
            proceedButton.isHidden = false
            let request = MKLocalSearch.Request()
            request.naturalLanguageQuery = text
            request.region = mapView.region
            let search = MKLocalSearch(request: request)
            
            timer?.invalidate()
            timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false, block: { [unowned self] (_) in
                search.start { response, _ in
                    guard let response = response else {
                        return
                    }
                    self.matchingItems = response.mapItems
                    self.placesTableView.reloadData()
                }
            })
        } else {
            proceedButton.isHidden = true
        }
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
        guard let placemark = selectedPin, let placeName = searchTF.text else { return }
        
        switch placeType {
        case .from:
            rideSearchDelegate?.setCoordinates(placemark: placemark, forPlace:.from)
            rideSearchDelegate?.continueAfterMapVC(from: .from, withPlaceName: placeName)
            navigationController?.popToRootViewController(animated: true)
            
        case .to:
            rideSearchDelegate?.setCoordinates(placemark: placemark, forPlace: .to)
            rideSearchDelegate?.continueAfterMapVC(from: .to, withPlaceName: placeName)
            navigationController?.popToRootViewController(animated: true)
            
            
        default:
            break
        }
    }
    
    
    @objc final func longTap(sender: UIGestureRecognizer){
        print("long tap")
        if sender.state == .began {
            let locationInView = sender.location(in: mapView)
            let locationOnMap = mapView.convert(locationInView, toCoordinateFrom: mapView)
            addAnnotation(location: locationOnMap)
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
    
    func setupLongTapRecognizer() {
        let longTapGesture = UILongPressGestureRecognizer(target: self, action: #selector(longTap))
        mapView.addGestureRecognizer(longTapGesture)
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
        dropPinZoomIn(placemark: place)
        dismissTableView()
        
    }
    
    
}

extension MapViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return searchTF.frame.height
    }
}

