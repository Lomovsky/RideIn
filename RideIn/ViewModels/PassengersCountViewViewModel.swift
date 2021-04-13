//
//  PassengersCountViewViewModel.swift
//  RideIn
//
//  Created by Алекс Ломовской on 13.04.2021.
//

import UIKit

final class PassengersCountViewViewModel: PassengersCountViewViewModelType {
    
    func addPassenger() {
        RideSearchViewViewModel.changePassengersCount(withOperation: .increase)
    }
    
    func removePassenger() {
        RideSearchViewViewModel.changePassengersCount(withOperation: .decrease)
    }
    
    func getPassengersCount() -> String {
        return RideSearchViewViewModel.getPassengers()
    }
    
    deinit {
        print("dealloccation \(self)")
    }
    
}
