//
//  LinkCConstructorProtocol.swift
//  RideIn
//
//  Created by Алекс Ломовской on 13.04.2021.
//

import UIKit
import MapKit

//MARK:- RideSearchDelegate
protocol RideSearchDelegate: class {
    func changePassengersCount(with operation: Operation)
    func getPassengersCount() -> String
    func continueAfterMapVC(from placeType: PlaceType, withPlaceName name: String)
    func setCoordinates(placemark: MKPlacemark, forPlace placeType: PlaceType)
    func setNavigationControllerHidden(to state: Bool, animated: Bool)
}

//MARK: - URLFactory
protocol URLFactory {
    func setCoordinates(coordinates: String, place: PlaceType)
    func setSeats(seats: String)
    func setDate(date: String)
    func makeURL() -> URL?
}

//MARK:- NetworkManager
protocol NetworkManager {
    func fetchRides(withURL url: URL, completionHandler: @escaping (Result<[Trip], Error>) -> Void)
}

//MARK:- DateTimeReturnable
protocol DateTimeReturnable {
    func getDateTime(format: DateFormat, from trip: Trip?, for placeType: PlaceType) -> String
}
