//
//  LinkCConstructorProtocol.swift
//  RideIn
//
//  Created by Алекс Ломовской on 13.04.2021.
//

import Foundation

protocol URLFactory {
    
    mutating func setCoordinates(coordinates: String, place: PlaceType)
    func makeURL() -> URL?
    
}
