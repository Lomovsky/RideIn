//
//  Enums.swift
//  RideIn
//
//  Created by Алекс Ломовской on 15.04.2021.
//

import Foundation

//Для правильного написания количества пассажиров
enum Declensions {
    case one
    case two
    case more
}

//To increase or decrease passengers count
enum Operation {
    case increase
    case decrease
}

//For rides requests
enum Query {
    static let country = "uk-UA"
    static let currency = "UAH"
    static let apiKey = "GU02DX6Tsap6aHH56HaZ0EnR9iGzibBq"
    static var fromCoordinates = String()
    static var toCoordinates = String()
}

//To operate with different types of requests
enum PlaceType {
    case from
    case to
}
