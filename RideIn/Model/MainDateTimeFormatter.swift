//
//  DateTimeManager.swift
//  RideIn
//
//  Created by Алекс Ломовской on 20.04.2021.
//

import UIKit


struct MainDateTimeFormatter: DateTimeFormatter {

    func getDateTime(format: DateFormat, from trip: Trip?, for placeType: PlaceType) -> String {

        switch placeType {
        case .department:
            switch format {
            case .dddmmyy:
                guard let trip = trip else { return "" }
                let dateStrings = trip.waypoints.first?.dateTime.components(separatedBy: "T")
                guard let date = dateStrings?.first else { return "" }
                return date

            case .hhmmss:
                guard let trip = trip else { return "" }
                let dateStrings = trip.waypoints.first?.dateTime.components(separatedBy: "T")
                guard var time = dateStrings?.last else { return "" }
                time.removeLast(3)
                return time
            }
            
        case .destination:
            switch format {
            case .dddmmyy:
                guard let trip = trip else { return "" }
                let dateStrings = trip.waypoints.last?.dateTime.components(separatedBy: "T")
                guard let date = dateStrings?.first else { return "" }
                return date

            case .hhmmss:
                guard let trip = trip else { return "" }
                let dateStrings = trip.waypoints.last?.dateTime.components(separatedBy: "T")
                guard var time = dateStrings?.last else { return "" }
                time.removeLast(3)
                return time
            }
        }
    }
    
}
