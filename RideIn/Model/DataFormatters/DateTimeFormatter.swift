//
//  MainDateTimeFormatter.swift
//  RideIn
//
//  Created by Алекс Ломовской on 06.05.2021.
//

import UIKit

protocol DateTimeFormatter {
    func getDateTime(format: DateFormat, from trip: Trip?, for placeType: PlaceType) -> String
    func getDateFrom(datePicker: UIDatePicker) -> String
}

//MARK: - MainDateTimeFormatter
struct MainDateTimeFormatter: DateTimeFormatter {
    
    func getDateTimeFrom(object: String, format: DateFormat) -> String {
        guard let dateTime = DateFormatter.defaultFormatter.date(from: object) else { return "" }
        
        switch format {
        case .dddmmyy:
            return DateFormatter.dateFormatter.string(from: dateTime)
            
        case .hhmmss:
            return DateFormatter.timeFormatter.string(from: dateTime)

        }
    }
    
    func getDateTime(format: DateFormat, from trip: Trip?, for placeType: PlaceType) -> String {
        guard let trip = trip else { return "" }

        switch placeType {
        case .department:
            guard let departureDateTime = DateFormatter.defaultFormatter.date(from: trip.waypoints.first?.dateTime ?? "") else { return "" }
            
            switch format {
            case .dddmmyy:
                return DateFormatter.dateFormatter.string(from: departureDateTime)
                
            case .hhmmss:
                return DateFormatter.timeFormatter.string(from: departureDateTime)
            }
            
        case .destination:
            guard let arrivingDateTime = DateFormatter.defaultFormatter.date(from: trip.waypoints.last?.dateTime ?? "") else { return "" }

            switch format {
            case .dddmmyy:
                return DateFormatter.dateFormatter.string(from: arrivingDateTime)

                
            case .hhmmss:
                return DateFormatter.timeFormatter.string(from: arrivingDateTime)

            }
        }
    }
    
    func getDateFrom(datePicker: UIDatePicker) -> String {
        return DateFormatter.defaultFormatter.string(from: datePicker.date)
    }
    
}


