//
//  RideSearchViewViewModel.swift
//  RideIn
//
//  Created by Алекс Ломовской on 13.04.2021.
//

import UIKit

enum Operation {
    case increase
    case decrease
}

enum PlaceType {
    case from
    case to
}

final class RideSearchViewViewModel: RideSearchViewViewModelType {
    
    static weak var rideSearchDelegate: RideSearchDelegate?

    private var _fromCoordinates = String()
    private var _toCoordinates = String()
    static var passengersCount = 5 {
        willSet(newValue) {
            print("\(newValue) " )
            RideSearchViewViewModel.rideSearchDelegate?.setPassangersCount(count: "\(newValue)")
        }
    }
    
    func setCoordinates(coordinates: String?, placeType: PlaceType) {
        switch placeType {
        case .from:
            guard let place = coordinates else { return }
            _fromCoordinates = place
            print("\(_fromCoordinates) \(self)")
            
        case .to:
            guard let place = coordinates else { return }
            _toCoordinates = place
        }
    }

    
    static func getPassengers() -> String {
        return "\(RideSearchViewViewModel.passengersCount)"
    }
    
    static func changePassengersCount(withOperation operation: Operation) {
        switch operation {
        case .increase:
            if passengersCount < 10 {
                passengersCount += 1
            }
            
        case .decrease:
            if passengersCount > 1 {
                passengersCount -= 1
            }
            
        }
    }
    
    func getCoordinates(placeType: PlaceType) -> String {
        switch placeType {
        case .from:
            return _fromCoordinates
            
        case .to:
            return _toCoordinates
        }
    }
    
    func search() {
        var factory = MainURLFactory()
        factory.setCoordinates(coordinates: _fromCoordinates, place: .from)
        factory.setCoordinates(coordinates: _toCoordinates, place: .to)
        if let url = factory.makeURL() {
            MainNetworkManager().fetchRides(withURL: url)
        }
    }
    
    
    deinit {
        print("dealloccation \(self)")
    }
    
}
