//
//  DataModel.swift
//  RideIn
//
//  Created by Алекс Ломовской on 15.04.2021.
//

import Foundation

// MARK: - Trips
struct Trips: Codable {
    let trips: [Trip]
    
    enum CodingKeys: String, CodingKey {
        case trips
    }
}

// MARK: - Trip
struct Trip: Codable {
    let link: String
    let waypoints: [Waypoint]
    let price: Price
    let vehicle: Vehicle?
    let distanceInMeters: Int
    
    enum CodingKeys: String, CodingKey {
        case link
        case waypoints
        case price
        case vehicle
        case distanceInMeters = "distance_in_meters"
    }
}

// MARK: - Price
struct Price: Codable {
    let amount: String
    let currency: String
}

// MARK: - Vehicle
struct Vehicle: Codable {
    let make: String?
    let model: String?
}

// MARK: - Waypoint
struct Waypoint: Codable {
    let dateTime: String
    let place: Place
    
    enum CodingKeys: String, CodingKey {
        case dateTime = "date_time"
        case place
    }
}

// MARK: - Place
struct Place: Codable {
    let city: String
    let address: String
    let latitude: Double
    let longitude: Double
    let countryCode: String
    
    enum CodingKeys: String, CodingKey {
        case city
        case address
        case latitude
        case longitude
        case countryCode = "country_code"
    }
}

extension Trip: Equatable {
    
    static func == (lhs: Trip, rhs: Trip) -> Bool {
        return lhs.link == rhs.link
    }
    
    
}
