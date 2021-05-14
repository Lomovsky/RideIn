//
//  MapKit+Extensions .swift
//  RideIn
//
//  Created by Алекс Ломовской on 11.05.2021.
//

import MapKit

extension MKMapView {
    static func createDefaultMapView() -> MKMapView {
        let mapView = MKMapView()
        mapView.translatesAutoresizingMaskIntoConstraints = false
        return mapView
    }
}
