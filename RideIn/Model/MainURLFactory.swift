//
//  LinkConstructor.swift
//  RideIn
//
//  Created by Алекс Ломовской on 13.04.2021.
//

import UIKit

struct MainURLFactory: URLFactory {
    
    
    private let _rideSearchVCViewModel: RideSearchViewViewModelType = RideSearchViewViewModel()
    private let _county = "uk-UA"
    private let _currency = "UAH"
    private let _apiKey = "GU02DX6Tsap6aHH56HaZ0EnR9iGzibBq"
    private var _fromCoordinates = String()
    private var _toCoordinates = String()
    private var _baseLink = "https://public-api.blablacar.com/api/v3/trips?from_coordinate=46.668396,32.646142&to_coordinate=46.966541,32.000077&locale=uk-UA&currency=UAH&key=GU02DX6Tsap6aHH56HaZ0EnR9iGzibBq"
    
    mutating func setCoordinates(coordinates: String, place: PlaceType) {
        
        switch place {
        case .from:
            _fromCoordinates = coordinates
            
        case .to:
            _toCoordinates = coordinates
        }
    }
    
    func makeURL() -> URL? {

        print("\(_fromCoordinates) IN FACTORY")
        let baseLink = "https://public-api.blablacar.com/api/v3/trips?from_coordinate=\(_fromCoordinates)&to_coordinate=\(_toCoordinates)&locale=\(_county)&currency=\(_currency)&key=\(_apiKey)"
        guard let url = URL(string: baseLink) else { return nil }
        return url
        
    }
    
    
    
}
