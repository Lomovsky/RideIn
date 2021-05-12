//
//  Constants.swift
//  RideIn
//
//  Created by Алекс Ломовской on 15.04.2021.
//

import Foundation

/// To write the word passenger correctly using number of passengers
enum Declensions {
    case one
    case two
    case more
}

/// To increase or decrease passengers count
enum Operation {
    case increase
    case decrease
}

/// For rides requests
enum Query {
    static let country = "uk-UA"
    static let currency = "UAH"
    static let apiKey = "GU02DX6Tsap6aHH56HaZ0EnR9iGzibBq"
    static var seats = "1"
    static var fromCoordinates = String()
    static var toCoordinates = String()
    static var date: String?
}

/// To operate with different types of requests
enum PlaceType {
    case department
    case destination
}

/// To get date or time from Trip
enum DateFormat {
    case dddmmyy
    case hhmmss
}

/// Animation type
enum AnimationState {
    case animated
    case dismissed
}

/// Views to be animated
enum AnimatingViews {
    case toContentSubview
    case toTextField
    case tableViewSubview
}

/// Request errors
enum NetworkManagerErrors: Error {
    case badRequest
    case noConnection
    case unableToMakeURL
    case noTrips
}

/// LogEvent
enum LogEvent: String {
    case e = "[‼️]" // error
    case i = "[ℹ️]" // info
    case d = "[💬]" // debug
    case v = "[🔬]" // verbose
    case w = "[⚠️]" // warning
    
    var value: String {
        get {
            return self.rawValue;
        }
    }
}

enum Notifications {
    case newRidesAvailable
    //...Other notifications 
}
