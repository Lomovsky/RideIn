//
//  DateFormatterExtensions.swift
//  RideIn
//
//  Created by Алекс Ломовской on 11.05.2021.
//

import Foundation

extension DateFormatter {
    
    static let defaultFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "yyyy-M-d'T'HH:mm:ss"
        return df
    }()
    
    static let dateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd"
        return df
    }()
    
    static let timeFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "HH:mm:ss"
        return df
    }()
}
