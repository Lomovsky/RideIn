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
        switch format {
        case .dddmmyy:
            let dateFormatterGet = DateFormatter()
            let dateFormatterPrint = DateFormatter()
            dateFormatterGet.dateFormat = "yyyy-M-d'T'HH:mm:ss"
            dateFormatterPrint.dateFormat = "yyyy-MM-dd"
            guard let date = dateFormatterGet.date(from: object) else { return "" }
            return dateFormatterPrint.string(from: date)
            
        case .hhmmss:
            let dateFormatterGet = DateFormatter()
            let dateFormatterPrint = DateFormatter()
            dateFormatterGet.dateFormat = "yyyy-M-d'T'HH:mm:ss"
            dateFormatterPrint.dateFormat = "HH:mm:ss"
            guard let date = dateFormatterGet.date(from: object) else { return "" }
            return dateFormatterPrint.string(from: date)
        }
    }
    
    func getDateTime(format: DateFormat, from trip: Trip?, for placeType: PlaceType) -> String {
        switch placeType {
        case .department:
            switch format {
            case .dddmmyy:
                guard let trip = trip else { return "" }
                let dateFormatterGet = DateFormatter()
                let dateFormatterPrint = DateFormatter()
                dateFormatterGet.dateFormat = "yyyy-M-d'T'HH:mm:ss"
                dateFormatterPrint.dateFormat = "yyyy-MM-dd"
                guard let date = dateFormatterGet.date(from: trip.waypoints.first?.dateTime ?? "") else { return "" }
                return dateFormatterPrint.string(from: date)
                
            case .hhmmss:
                guard let trip = trip else { return "" }
                let dateFormatterGet = DateFormatter()
                let dateFormatterPrint = DateFormatter()
                dateFormatterGet.dateFormat = "yyyy-M-d'T'HH:mm:ss"
                dateFormatterPrint.dateFormat = "HH:mm:ss"
                guard let date = dateFormatterGet.date(from: trip.waypoints.first?.dateTime ?? "") else { return "" }
                return dateFormatterPrint.string(from: date)
            }
            
        case .destination:
            switch format {
            case .dddmmyy:
                guard let trip = trip else { return "" }
                let dateFormatterGet = DateFormatter()
                let dateFormatterPrint = DateFormatter()
                dateFormatterGet.dateFormat = "yyyy-M-d'T'HH:mm:ss"
                dateFormatterPrint.dateFormat = "yyyy-MM-dd"
                guard let date = dateFormatterGet.date(from: trip.waypoints.last?.dateTime ?? "") else { return "" }
                return dateFormatterPrint.string(from: date)
                
            case .hhmmss:
                guard let trip = trip else { return "" }
                let dateFormatterGet = DateFormatter()
                let dateFormatterPrint = DateFormatter()
                dateFormatterGet.dateFormat = "yyyy-M-d'T'HH:mm:ss"
                dateFormatterPrint.dateFormat = "HH:mm:ss"
                guard let date = dateFormatterGet.date(from: trip.waypoints.last?.dateTime ?? "") else { return "" }
                return dateFormatterPrint.string(from: date)
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
