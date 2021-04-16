//
//  LinkCConstructorProtocol.swift
//  RideIn
//
//  Created by Алекс Ломовской on 13.04.2021.
//

import Foundation

protocol URLFactory {
    
    func setCoordinates(coordinates: String, place: PlaceType)
    func setSeats(seats: String)
    func makeURL() -> URL?
    
}
