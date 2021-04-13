//
//  RideSearchVC+Extenstions.swift
//  RideIn
//
//  Created by Алекс Ломовской on 13.04.2021.
//

import UIKit

//MARK:- Helping methods
extension RideSearchViewController {
    
    @objc final func setDate() {
        
    }
    
    @objc final func setPassengersCount() {
        coordinator?.showPassengersVC(withPassengersCount: RideSearchViewViewModel.getPassengers())
    }
    
    @objc final func search() {
        viewModel.search()
    }
    
}

//MARK:- RideSearchViewModelDelegate
extension RideSearchViewController: RideSearchDelegate {
    
    func setPassangersCount(count: String) {
        passengersButton.setTitle(count + " пассажиров", for: .normal)
    }
}


//MARK: - TextField Delegate

extension RideSearchViewController: UITextFieldDelegate {
    
    @objc final func textFieldDidChange(_ textField: UITextField) {
        switch textField {
        case fromTextField:
            viewModel.setCoordinates(coordinates: textField.text, placeType: .from)
            
        case toTextField:
            viewModel.setCoordinates(coordinates: textField.text, placeType: .to)
            
        default:
            break
        }
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case fromTextField:
            return true
            
        case toTextField:
            return true
        default:
            return false
        }
    }
}
