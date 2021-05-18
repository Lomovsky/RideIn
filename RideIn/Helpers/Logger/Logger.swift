//
//  Logger.swift
//  RideIn
//
//  Created by Алекс Ломовской on 06.05.2021.
//

import Foundation

class Log {
  
  fileprivate static let dateFormatter: DateFormatter = {
    let df = DateFormatter()
    df.dateFormat = "yyyy-MM-dd hh:mm:ssSSS"
    df.locale = Locale.current
    df.timeZone = TimeZone.current
    return df
  }()
  
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
      return last
    }
    return ""
  }
}

private extension Date {
  func toString() -> String {
    return Log.dateFormatter.string(from: self as Date)
  }
}

