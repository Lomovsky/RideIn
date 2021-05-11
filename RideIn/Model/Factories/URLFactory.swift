//
//  MainURLFactory.swift
//  RideIn
//
//  Created by Алекс Ломовской on 06.05.2021.
//

import Foundation

protocol URLFactory {
    func setCoordinates(coordinates: String, place: PlaceType)
    func setSeats(seats: String)
    func setDate(date: String?)
    func makeURL() -> URL?
}

//MARK:- USLFactory
struct MainURLFactory: URLFactory {
    
    func setCoordinates(coordinates: String, place: PlaceType) {
        switch place {
        case .department: Query.fromCoordinates = coordinates
            
        case .destination: Query.toCoordinates = coordinates
        }
    }
    
    func setSeats(seats: String) {
        Query.seats = seats
    }
    
    func setDate(date: String?) {
        Query.date = date
    }
    
    func makeURL() -> URL? {
        if Query.date != nil {
            let baseLink = "https://public-api.blablacar.com/api/v3/trips?from_coordinate=\(Query.fromCoordinates)&to_coordinate=\(Query.toCoordinates)&locale=\(Query.country)&currency=\(Query.currency)&seats=\(Query.seats)&count=50&start_date_local=\(Query.date!)&key=\(Query.apiKey)"
            
            guard let url = URL(string: baseLink) else { return nil }
            return url
            
        } else {
            let baseLink = "https://public-api.blablacar.com/api/v3/trips?from_coordinate=\(Query.fromCoordinates)&to_coordinate=\(Query.toCoordinates)&locale=\(Query.country)&currency=\(Query.currency)&seats=\(Query.seats)&count=50&key=\(Query.apiKey)"
            
            let url = URL(string: baseLink)
            return url
        }
    }
}
