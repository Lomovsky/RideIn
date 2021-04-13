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
        let textFieldAnimator = TextFieldAnimator()
        let viewAnimator = ViewAnimator()
        
        switch textField {
        case fromTextField:
            tableViewSubview.topAnchor.constraint(equalTo: fromTextField.bottomAnchor).isActive = true
            tableViewSubview.topAnchor.constraint(equalTo: toTextField.bottomAnchor).isActive = false
            
            fromTextFieldTapped = true
            tableViewSubview.isHidden = false
            toTextField.isHidden = true
            dateButton.isHidden = true
            searchButton.isHidden = true
            bottomLine.isHidden = true
            topLine.isHidden = true
            passengersButton.isHidden = true
            textFieldAnimator.animateControl(textField, navigationController ?? UINavigationController())
            viewAnimator.animateView(tableViewSubview, navigationController ?? UINavigationController())
            
        case toTextField:
            tableViewSubview.topAnchor.constraint(equalTo: fromTextField.bottomAnchor).isActive = false
            tableViewSubview.topAnchor.constraint(equalTo: toTextField.bottomAnchor).isActive = true
            tableViewSubview.isHidden = false

            UIView.animate(withDuration: 0.3) {
//                self.toTextField.topAnchor.constraint(equalTo: self.fromTextField.bottomAnchor, constant: 15).isActive = false
//                self.toTextField.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 30).isActive = true
                self.navigationController?.setNavigationBarHidden(true, animated: true)
                self.toTextField.frame = CGRect(x: self.toTextField.frame.origin.x,
                                                y: self.toTextField.frame.origin.y -
                                                    self.navigationController!.navigationBar.frame.height -
                                                    (self.view.frame.height * 0.7),
                                                width: self.toTextField.frame.width,
                                                height: self.toTextField.frame.height)
                self.tableViewSubview.frame = CGRect(x: self.tableViewSubview.frame.origin.x,
                                                     y: self.tableViewSubview.frame.origin.y - self.navigationController!.navigationBar.frame.height,
                                                     width: self.tableViewSubview.frame.width,
                                                     height: self.tableViewSubview.frame.height)
                self.tableViewSubview.alpha = 1.0
            }
            fromTextField.isHidden = true
            dateButton.isHidden = true
            searchButton.isHidden = true
            bottomLine.isHidden = true
            topLine.isHidden = true
            passengersButton.isHidden = true
//            textFieldAnimator.animateSecondControl(textField, navigationController ?? UINavigationController())
//            viewAnimator.animateView(tableViewSubview, navigationController ?? UINavigationController())
            
        default:
            break
        }
    }
    
    func dismissAnimation(textField: UITextField) {
        let textFieldAnimator = TextFieldAnimator()
        let viewAnimator = ViewAnimator()
        
        switch textField {
        case fromTextField:
            textFieldAnimator.undoViewAnimation(textField, navigationController ?? UINavigationController())
            viewAnimator.undoViewAnimation(tableViewSubview,  navigationController ?? UINavigationController())
            fromTextFieldTapped = false
            toTextField.isHidden = false
            dateButton.isHidden = false
            searchButton.isHidden = false
            bottomLine.isHidden = false
            topLine.isHidden = false
            passengersButton.isHidden = false
            tableViewSubview.isHidden = true

        case toTextField:
            toTextField.topAnchor.constraint(equalTo: fromTextField.bottomAnchor, constant: 15).isActive = true
//            toTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 30).isActive = false
            
            toTextField.removeConstraint(toTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 30))
            textFieldAnimator.undoSecondControlAnimation(textField, navigationController ?? UINavigationController())
            viewAnimator.undoViewAnimation(tableViewSubview,  navigationController ?? UINavigationController())
            toTextFieldTapped = false
            fromTextField.isHidden = false
            dateButton.isHidden = false
            searchButton.isHidden = false
            bottomLine.isHidden = false
            topLine.isHidden = false
            passengersButton.isHidden = false
//            toTextField.topAnchor.constraint(equalTo: fromTextField.bottomAnchor, constant: 15).isActive = true
//            toTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 30).isActive = false
            tableViewSubview.isHidden = true

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

