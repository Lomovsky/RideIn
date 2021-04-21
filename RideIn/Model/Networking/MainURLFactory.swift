//
//  LinkConstructor.swift
//  RideIn
//
//  Created by Алекс Ломовской on 13.04.2021.
//

import UIKit


struct MainURLFactory: URLFactory {
    
    func setCoordinates(coordinates: String, place: PlaceType) {
        
        switch place {
        case .from: Query.fromCoordinates = coordinates
            
        case .to: Query.toCoordinates = coordinates
        }
    }
    
    func setSeats(seats: String) {
        Query.seats = seats
    }
    
    func setDate(date: String) {
        Query.date = date
    }
    
    func makeURL() -> URL? {
        if Query.date != nil {
            let baseLink = "https://public-api.blablacar.com/api/v3/trips?from_coordinate=\(Query.fromCoordinates)&to_coordinate=\(Query.toCoordinates)&locale=\(Query.country)&currency=\(Query.currency)&seats=\(Query.seats)&count=50&start_date_local=\(Query.date!)&key=\(Query.apiKey)"
            
            guard let url = URL(string: baseLink) else { return nil }
            return url
            
        } else {
            let baseLink = "https://public-api.blablacar.com/api/v3/trips?from_coordinate=\(Query.fromCoordinates)&to_coordinate=\(Query.toCoordinates)&locale=\(Query.country)&currency=\(Query.currency)&seats=\(Query.seats)&count=50&key=\(Query.apiKey)"
            
            guard let url = URL(string: baseLink) else { return nil }
            return url
        }
    }
    
}
