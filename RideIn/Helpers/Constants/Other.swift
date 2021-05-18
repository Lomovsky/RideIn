//
//  Constants.swift
//  RideIn
//
//  Created by Алекс Ломовской on 15.04.2021.
//

import Foundation

/// To increase or decrease passengers count
enum Operation {
  case increase
  case decrease
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
