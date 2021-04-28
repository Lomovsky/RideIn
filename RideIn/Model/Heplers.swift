//
//  Heplers.swift
//  RideIn
//
//  Created by Алекс Ломовской on 28.04.2021.
//

import MapKit

//MARK:- MainDistanceCalculator
struct MainDistanceCalculator: DistanceCalculator {
    
    func compareDistances(first: CLLocationDistance, second: CLLocationDistance) -> Bool {
        return second.isLess(than: first)
    }
    
    func getDistanceBetween(userLocation: CLLocation, departurePoint: CLLocation) -> CLLocationDistance {
        return userLocation.distance(from: departurePoint)
    }
}

//MARK: - MainDateTimeFormatter
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


//MARK:- Logger
class Log {
    
    fileprivate static let dateFormatter: DateFormatter = {
        let df = DateFormatter();
        df.dateFormat = "yyyy-MM-dd hh:mm:ssSSS";
        df.locale = Locale.current;
        df.timeZone = TimeZone.current;
        return df;
    }();
    
    private static var isLoggingEnabled: Bool {
        #if DEBUG
        return true
        #else
        return false
        #endif
    }
    
    class func e( _ object: Any, filename: String = #file, line: Int = #line, funcName: String = #function) {
        if isLoggingEnabled {
            print("\(Date().toString()) \(LogEvent.e.value)[\(sourceFileName(filePath: filename))]:\(line) \(funcName) -> \(object)");
        }
    }
    
    class func i( _ object: Any, filename: String = #file, line: Int = #line, funcName: String = #function) {
        if isLoggingEnabled {
            print("\(Date().toString()) \(LogEvent.i.value)[\(sourceFileName(filePath: filename))]:\(line) \(funcName) -> \(object)");
        }
    }
    
    class func d( _ object: Any, filename: String = #file, line: Int = #line, funcName: String = #function) {
        if isLoggingEnabled {
            print("\(Date().toString()) \(LogEvent.d.value)[\(sourceFileName(filePath: filename))]:\(line) \(funcName) -> \(object)")
        }
    }
    
    class func v( _ object: Any, filename: String = #file, line: Int = #line, funcName: String = #function) {
        if isLoggingEnabled {
            print("\(Date().toString()) \(LogEvent.v.value)[\(sourceFileName(filePath: filename))]:\(line) \(funcName) -> \(object)")
        }
    }
    
    class func w( _ object: Any, filename: String = #file, line: Int = #line, funcName: String = #function) {
        if isLoggingEnabled {
            print("\(Date().toString()) \(LogEvent.w.value)[\(sourceFileName(filePath: filename))]:\(line) \(funcName) -> \(object)")
        }
    }
    
    
    private class func sourceFileName(filePath: String) -> String {
        if let last = filePath.components(separatedBy: "/").last {
            return last;
        }
        return ""
    }
}

private extension Date {
    func toString() -> String {
        return Log.dateFormatter.string(from: self as Date);
    }
}

