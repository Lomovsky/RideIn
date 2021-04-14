//
//  RideSearchVC+Extensions.swift
//  RideIn
//
//  Created by Алекс Ломовской on 13.04.2021.
//

import UIKit


//MARK:- Helping methods
extension RideSearchViewController {
    
    func setCount() {
        switch passengerDeclension {
        case .one:
            passengersButton.setTitle("\(passengersCount) пассажир", for: .normal)
            
        case .two:
            passengersButton.setTitle("\(passengersCount) пассажира", for: .normal)
            
        default:
            passengersButton.setTitle("\(passengersCount) пассажиров", for: .normal)
            
        }
    }
    
    @objc final func setPassengersCount() {
        let vc = PassengersCountViewController()
        vc.rideSearchDelegate = self
        navigationController?.present(vc, animated: true, completion: nil)
    }
    
    @objc final func search() {
        guard let url = urlFactory.makeURL() else { return }
        networkManager.fetchRides(withURL: url)
    }
    
    
    func animate(textField: UITextField) {
        
        switch textField {
        case fromTextField:
            
            
            fromTextFieldTapped = true
            toTextField.isHidden = true
            dateButton.isHidden = true
            searchButton.isHidden = true
            bottomLine.isHidden = true
            topLine.isHidden = true
            passengersButton.isHidden = true
            
            
            UIView.animate(withDuration: 0.3) {
                self.navigationController?.setNavigationBarHidden(true, animated: true)
                self.tableViewSubviewTopConstraint.isActive = false
                self.tableViewSubviewTopConstraint = NSLayoutConstraint(item: self.tableViewSubview,
                                                                        attribute: .top,
                                                                        relatedBy: .equal,
                                                                        toItem: self.fromTextField,
                                                                        attribute: .bottom,
                                                                        multiplier: 1,
                                                                        constant: 0)
                self.tableViewSubviewTopConstraint.isActive = true
                self.tableViewSubview.alpha = 1.0
                self.view.layoutIfNeeded()
            }
            tableViewSubview.isHidden = false
            print("\(fromTextField.frame) fromTF")
            
        case toTextField:
            tableViewSubview.topAnchor.constraint(equalTo: fromTextField.bottomAnchor).isActive = false
            tableViewSubview.topAnchor.constraint(equalTo: toTextField.bottomAnchor).isActive = true
            view.setNeedsLayout()
            UIView.animate(withDuration: 0.3, delay: 0, options: [.curveEaseOut], animations: {
                self.toTFTopConstraint.isActive = false
                self.tableViewSubviewTopConstraint.isActive = false
                self.navigationController?.setNavigationBarHidden(true, animated: true)
                self.toTFTopConstraint = NSLayoutConstraint(item: self.toTextField,
                                                            attribute: .top,
                                                            relatedBy: .equal,
                                                            toItem: self.view.safeAreaLayoutGuide,
                                                            attribute: .top,
                                                            multiplier: 1,
                                                            constant: 30)
                self.tableViewSubviewTopConstraint = NSLayoutConstraint(item: self.tableViewSubview,
                                                                        attribute: .top,
                                                                        relatedBy: .equal,
                                                                        toItem: self.toTextField,
                                                                        attribute: .bottom,
                                                                        multiplier: 1,
                                                                        constant: 0)
                self.toTFTopConstraint.isActive = true
                self.tableViewSubviewTopConstraint.isActive = true
                self.tableViewSubview.alpha = 1.0
                self.view.layoutIfNeeded()
            })
            tableViewSubview.isHidden = false
            fromTextField.isHidden = true
            dateButton.isHidden = true
            searchButton.isHidden = true
            bottomLine.isHidden = true
            topLine.isHidden = true
            passengersButton.isHidden = true
            print(toTextField.frame)
            
        default:
            break
        }
    }
    
    func dismissAnimation(textField: UITextField) {
        
        switch textField {
        case fromTextField:
            UIView.animate(withDuration: 0.3) {
                self.navigationController?.setNavigationBarHidden(false, animated: true)
                self.tableViewSubview.alpha = 0.0
                self.view.layoutIfNeeded()
            }
            
            fromTextFieldTapped = false
            toTextField.isHidden = false
            dateButton.isHidden = false
            searchButton.isHidden = false
            bottomLine.isHidden = false
            topLine.isHidden = false
            passengersButton.isHidden = false
            tableViewSubview.isHidden = true
            print("\(fromTextField.frame) fromTF")
            
        case toTextField:
            view.setNeedsLayout()
            UIView.animate(withDuration: 0.3, delay: 0, options: [.curveEaseOut], animations: {
                self.navigationController?.setNavigationBarHidden(false, animated: true)
                self.toTFTopConstraint.isActive = false
                self.toTFTopConstraint = NSLayoutConstraint(item: self.toTextField,
                                                            attribute: .top,
                                                            relatedBy: .equal,
                                                            toItem: self.view.safeAreaLayoutGuide,
                                                            attribute: .top,
                                                            multiplier: 1,
                                                            constant: 45 + (self.view.frame.height * 0.07))
                self.toTFTopConstraint.isActive = true
                self.tableViewSubview.alpha = 0.0
                self.view.layoutIfNeeded()
            })
            toTextFieldTapped = false
            fromTextField.isHidden = false
            dateButton.isHidden = false
            searchButton.isHidden = false
            bottomLine.isHidden = false
            topLine.isHidden = false
            passengersButton.isHidden = false
            tableViewSubview.isHidden = true
            print(toTextField.frame)
            
            
        default:
            break
        }
    }
}




//MARK: - TextField Delegate

extension RideSearchViewController: UITextFieldDelegate {
    
    @objc final func textFieldDidChange(_ textField: UITextField) {
        switch textField {
        case fromTextField:
            guard let text = fromTextField.text, text != "" else { return }
            urlFactory.setCoordinates(coordinates: text, place: .from)
            
        case toTextField:
            guard let text = toTextField.text, text != "" else { return }
            urlFactory.setCoordinates(coordinates: text, place: .to)
            
        default:
            break
        }
    }
    
    @objc func textFieldHasBeenActivated(textField: UITextField) {
        
        switch textField {
        case fromTextField:
            if !fromTextFieldTapped {
                fromTextFieldTapped = true
                animate(textField: fromTextField)
            }
            
        case toTextField:
            if !toTextFieldTapped {
                toTextFieldTapped = true
                animate(textField: toTextField)
            }
            
        default:
            break
        }
    }
    
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case fromTextField:
            fromTextField.resignFirstResponder()
            dismissAnimation(textField: textField)
            
            return true
            
        case toTextField:
            toTextField.resignFirstResponder()
            dismissAnimation(textField: textField)
            return true
            
        default:
            return false
        }
    }
    
}

extension RideSearchViewController: RideSearchDelegate {
    
    func changePassengersCount(with operation: Operation) {
        switch operation {
        case .increase:
            if passengersCount < 10 {
                passengersCount += 1
                setCount()
            }
            
        case .decrease:
            if passengersCount > 1 {
                passengersCount -= 1
                setCount()
                
            }
        }
    }
    
    func getPassengersCount() -> String {
        return "\(passengersCount)"
    }
}

