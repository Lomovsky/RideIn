//
//  MapTableViewDataProvider.swift
//  RideIn
//
//  Created by Алекс Ломовской on 05.05.2021.
//

import UIKit
import MapKit

final class MapTableViewDataProvider: NSObject, PlacesSearchTableViewDataProvider {
    
    //MARK: Declarations -
    var delegate: MapTableViewDataProviderDelegate?
    
    ///The array of items that match to users search
    var matchingItems = [MKMapItem]()
    
    /// Parent viewController that asks for data
    weak var parentVC: UIViewController?
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return matchingItems.count
    }
    
    //MARK: cellForRowAt
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: MapTableViewCell.reuseIdentifier, for: indexPath) as! MapTableViewCell
        let place = matchingItems[indexPath.row].placemark
        cell.textLabel?.text = place.name
        cell.update(with: place.name)
        guard let country = place.country, let administrativeArea = place.administrativeArea, let name = place.name else { return cell }
        cell.update(with: ("\(country), \(administrativeArea), \(name)"), object2: MainMapKitPlacesSearchManager.parseAddress(selectedItem: place))
        return cell
    }
    
    //MARK: didSelectRowAt
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let place = matchingItems[indexPath.row].placemark
        delegate?.didSelectCell(passedData: place)
        guard let vc = parentVC as? MapViewController else { return }
        vc.mapView.removeAnnotations(vc.mapView.annotations)
        vc.mapKitDataProvider.mapKitDataManager.dropPinZoomIn(placemark: place, zoom: true)
        vc.dismissTableView()
    }
    
    //MARK: heightForRowAt
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let vc = parentVC as? MapViewController else { return 0.0 }
        return vc.searchTF.frame.height
    }
    
}
