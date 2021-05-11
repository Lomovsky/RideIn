//
//  RideSearchTableviewDataProvider.swift
//  RideIn
//
//  Created by Алекс Ломовской on 05.05.2021.
//

import UIKit
import MapKit

protocol PlacesSearchTableViewDataProvider: UITableViewDelegate, UITableViewDataSource {
    var matchingItems: [MKMapItem] { get set }
    var parentVC: UIViewController? { get set }
}

protocol RideSearchTableViewDataProviderDelegate {
    func didSelectCell(passedData name: String?, coordinates: String)
}

final class RideSearchTableviewDataProvider: NSObject, PlacesSearchTableViewDataProvider {
    
    //MARK: Declarations -
    /// Parent viewController that asks for data
    weak var parentVC: UIViewController?
    
    var delegate: RideSearchTableViewDataProviderDelegate?
    
    ///The array of items that match to users search
    var matchingItems = [MKMapItem]()
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return matchingItems.count
    }
    
    //MARK: cellForRowAt -
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeue(cellClass: RideSearchTableViewCell.self, forIndexPath: indexPath)
        let place = matchingItems[indexPath.row].placemark
        guard let country = place.country,
              let administrativeArea = place.administrativeArea,
              let name = place.name
        else { cell.update(with: place.name); return cell }
        cell.update(with: "\(country), \(administrativeArea), \(name)",
                    object2: MainMapKitPlacesSearchManager.parseAddress(selectedItem: place))
        return cell
    }
    
    
    
    //MARK: didSelectRowAt
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let placemark = matchingItems[indexPath.row].placemark
        let latitude = placemark.coordinate.latitude
        let longitude = placemark.coordinate.longitude
        let coordinates = "\(latitude),\(longitude)"
        delegate?.didSelectCell(passedData: placemark.name, coordinates: coordinates)
        Log.i("\(self) selected")
        
        guard let vc = parentVC as? RideSearchViewController else { return }
        switch vc.controllerDataProvider.placeType {
        case .department:
            vc.departureTextField.text = placemark.name
            vc.controllerDataProvider.departureCoordinates = coordinates
            vc.dismissDepartureTextField()
            
        case .destination:
            vc.destinationTextField.text = placemark.name
            vc.controllerDataProvider.destinationCoordinates = coordinates
            vc.dismissDestinationTextField()
            
        default: break
        }
    }
    
    //MARK: heightForRowAt
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let vc = parentVC as? RideSearchViewController else { return 0.0 }
        return vc.view.frame.height * 0.09
    }
}
