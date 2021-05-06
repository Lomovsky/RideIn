//
//  MainMapKitPlacesSearchManager.swift
//  RideIn
//
//  Created by Алекс Ломовской on 05.05.2021.
//

import UIKit
import MapKit

struct MainMapKitPlacesSearchManager: MapKitPlacesSearchManager {
    
    /// This method is responsible for searching for locations&places by user request
    /// - Parameters:
    ///   - keyWord: the place name user types
    ///   - region: region in which to search (commonly mapKit region)
    ///   - completion: completion handler to work with data that the method returns
    static func searchForPlace(with keyWord: String?, inRegion region: MKCoordinateRegion,
                               completion: @escaping (_ matchingItems: [MKMapItem], _ error: Error?) -> Void) {
        guard let text = keyWord, text != "" else { return }
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = text
        request.region = region
        request.resultTypes = .address
        let search = MKLocalSearch(request: request)
        search.start { response, error in
            guard let response = response else { return }
            completion(response.mapItems, error)
        }
    }
    
    /// This method is responsible for parsing address to more detailed and user-friendly style
    /// - Parameter selectedItem: the placemark which data will be precessed
    /// - Returns: string address line
    static func parseAddress(selectedItem: MKPlacemark) -> String {
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
