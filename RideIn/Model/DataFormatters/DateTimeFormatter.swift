//
//  MainDateTimeFormatter.swift
//  RideIn
//
//  Created by Алекс Ломовской on 06.05.2021.
//

import UIKit

//MARK: - MainDateTimeFormatter
struct MainDateTimeFormatter: DateTimeFormatter {

    func getDateTimeFrom(object: String, format: DateFormat) -> String {
        switch format {
        case .dddmmyy:
            let dateStrings = object.components(separatedBy: "T")
            guard let date = dateStrings.first else { return "" }
            return date
            
        case .hhmmss:
            let dateStrings = object.components(separatedBy: "T")
            guard let date = dateStrings.last else { return "" }
            return date
        }
    }
    
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
    
    func getDateFrom(datePicker: UIDatePicker) -> String {
        guard let day = Calendar.current.dateComponents([.day], from: datePicker.date).day,
              let month = Calendar.current.dateComponents([.month], from: datePicker.date).month,
              let year = Calendar.current.dateComponents([.year], from: datePicker.date).year
        else { return "" }
        let yearString = "\(String(describing: year))"
        var dayString = "\(String(describing: day))"
        var monthString = "\(String(describing: month))"
        if day < 10 { dayString = "0\(String(describing: day))" }
        if month < 10 { monthString = "0\(String(describing: month))" }
        let date = yearString + "-" + monthString + "-" + dayString + "T00:00:00"
        return date
    }
    
}
