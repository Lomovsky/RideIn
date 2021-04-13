//
//  RideSearchVCViewModel.swift
//  RideIn
//
//  Created by Алекс Ломовской on 13.04.2021.
//

import Foundation

protocol RideSearchViewViewModelType {
    
    static var rideSearchDelegate: RideSearchDelegate? { get set }
    static func changePassengersCount(withOperation operation: Operation)
    static func getPassengers() -> String
    func setCoordinates(coordinates: String?, placeType: PlaceType)
    func getCoordinates(placeType: PlaceType) -> String
    func search()
}
