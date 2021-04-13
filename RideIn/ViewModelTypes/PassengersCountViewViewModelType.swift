//
//  PassengersCountViewViewModelType.swift
//  RideIn
//
//  Created by Алекс Ломовской on 13.04.2021.
//

import Foundation

protocol PassengersCountViewViewModelType {
    
    func addPassenger()
    func removePassenger()
    func getPassengersCount() -> String 
    
}
