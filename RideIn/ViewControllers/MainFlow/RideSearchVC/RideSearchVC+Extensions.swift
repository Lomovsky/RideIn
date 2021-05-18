//
//  RideSearchVC+Extensions.swift
//  RideIn
//
//  Created by Алекс Ломовской on 13.04.2021.
//

import UIKit
import MapKit

//MARK:- Targets&Actions
extension RideSearchViewController {
  @objc final func passengersCountButtonTapped() {
    onChoosePassengersCountSelected?(self)
  }
  
  /// This method is triggered when user tap searchButton. Calls search method from dataProvider
  @objc final func searchButtonTapped() {
    controllerDataProvider.search()
  }
  
  /// Is triggered when the user press back button on departureTF
  @objc func dismissDepartureTextField() {
    departureTextField.resignFirstResponder()
    checkTextFieldsForEmptiness()
    dismissAnimation(textField: departureTextField)
  }
  
  /// Is triggered when the user press back button on destinationTF
  @objc final func dismissDestinationTextField() {
    destinationTextField.resignFirstResponder()
    checkTextFieldsForEmptiness() 
    dismissAnimation(textField: destinationTextField)
  }
  
  ///This method calls on map selected
  @objc final func showMapButtonTapped() {
    onMapSelected?(controllerDataProvider.placeType, self)
    controllerDataProvider.shouldNavigationControllerBeHiddenAnimated = (true, false)
  }
  
  /// This method changes date property with the new date from UIDatePicker
  /// - Parameter sender: The sender of type UIDatePicker from which we get new date
  @objc final func changeDateWith(sender: UIDatePicker) {
    controllerDataProvider.date = MainDateTimeFormatter().getDateFrom(date: sender.date)
  }
}

//MARK:- Helping methods
extension RideSearchViewController {
  func changeSelectionState(with state: Bool) {
    guard state else { return }
    departureTextField.isSelected = true
    departureTextField.becomeFirstResponder()
    animate(textField: departureTextField)
    controllerDataProvider.placeType = .department
  }
  
  /// This method is used for configuring "searchButton" and activity indicator state.
  /// Triggered then user press "searchButton" to start activity indicator and hide button to
  /// show user that search has begun.
  /// - Parameter enabled: the state according to which we configure button and activity indicator
  func configureIndicatorAndButton(indicatorEnabled enabled: Bool) {
    if enabled {
      activityIndicator.startAnimating()
      activityIndicator.isHidden = false
      searchButton.isHidden = true
    } else {
      activityIndicator.stopAnimating()
      activityIndicator.isHidden = true
      searchButton.isHidden = false
    }
  }
  
  //TODO
  ///This method configures passengersButton with given number of passengers according to declension
  func setPassengersCountWithDeclension() {
    let localizedCountFormat = NSLocalizedString("Passengers count",
                                                 comment: "Passengers count string format to be found in Localized.stringsdict")
    let localizedCount = String.localizedStringWithFormat(localizedCountFormat, controllerDataProvider.passengersCount)
    passengersButton.setTitle(localizedCount, for: .normal)
  }
  
  /// This method asks dataProvider to search places with the given key word
  /// - Parameter word: the keyword for the search (e.g. city name)
  private func searchPlaces(withWord word: String?) {
    controllerDataProvider.searchPlaces(word: word)
  }    
}


//MARK: - TextField Delegate
extension RideSearchViewController: UITextFieldDelegate {
  /// This method is called each time the user types a character into textField
  /// Calls "checkTextFieldsForEmptiness" function to configure "searchButton" displaying
  /// Calls methods to search places
  /// - Parameter textField: the text field from which calls this method (AKA sender)
  @objc final func textFieldDidChange(_ textField: UITextField) {
    checkTextFieldsForEmptiness()
    
    switch textField {
    case departureTextField: searchPlaces(withWord: departureTextField.text)
      
    case destinationTextField: searchPlaces(withWord: destinationTextField.text)
      
    default: break
    }
  }
  
  /// This method is called each time user tap on a textField
  /// Sets chosenTF & placeType properties respectively to chosen textField
  /// - Parameter textField: the text field from which calls this method (AKA sender)
  @objc func textFieldHasBeenActivated(textField: UITextField) {
    
    switch textField {
    case departureTextField:
      controllerDataProvider.chosenTF = departureTextField
      if !controllerDataProvider.departureTextFieldTapped {
        controllerDataProvider.departureTextFieldTapped = true
        animate(textField: departureTextField)
      }
      controllerDataProvider.placeType = .department
      
    case destinationTextField:
      controllerDataProvider.chosenTF = destinationTextField
      if !controllerDataProvider.destinationTextFieldTapped {
        controllerDataProvider.destinationTextFieldTapped = true
        animate(textField: destinationTextField)
      }
      controllerDataProvider.placeType = .destination
      
    default:
      break
    }
  }
  
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    textField.resignFirstResponder()
    return true
  }
  
  /// This methods checks textField for emptiness to configure "searchButton"s state
  private func checkTextFieldsForEmptiness() {
    guard !(departureTextField.text?.isEmpty ?? true), departureTextField.text != "",
          !(destinationTextField.text?.isEmpty ?? true), departureTextField.text != "" else {
      searchButton.isHidden = true
      return }
    searchButton.isHidden = false
  }
}

//MARK: - RideSearchDelegate
extension RideSearchViewController: RideSearchDelegate {
  /// This method of RideSearchDelegate is responsible for changing passengersCount property respectively to given operation type
  /// - Parameter operation: the operation type of type Operation
  func changePassengersCount(with operation: Operation) {
    switch operation {
    case .increase: if controllerDataProvider.passengersCount < 10 { controllerDataProvider.passengersCount += 1 }
      
    case .decrease: if controllerDataProvider.passengersCount > 1 { controllerDataProvider.passengersCount -= 1 }
    }
    setPassengersCountWithDeclension()
  }
  
  /// This method is used for getting passengers count from passengersCount property
  /// - Returns: passengers count of type String
  func getPassengersCount() -> String {
    return "\(controllerDataProvider.passengersCount)"
  }
  
  /// Sets coordinates and place name with a given placemark for specific placeType
  /// - Parameters:
  ///   - placemark: the placemark pinned on mapVC or any other MKMapView
  ///   - placeType: the placeType for which the data is set
  func setCoordinates(with placemark: MKPlacemark, forPlace placeType: PlaceType) {
    guard let longitude = placemark.location?.coordinate.longitude,
          let latitude = placemark.location?.coordinate.latitude else { return }
    
    switch placeType {
    case .department:
      controllerDataProvider.departureCoordinates = "\(latitude),\(longitude)"
      controllerDataProvider.departureCLLocation = CLLocation(latitude: latitude, longitude: longitude)
      departureTextField.text = placemark.name
      dismissDepartureTextField()
      
    case .destination:
      controllerDataProvider.destinationCoordinates = "\(latitude),\(longitude)"
      destinationTextField.text = placemark.name
      dismissDestinationTextField()
    }
  }
  
  /// This method is responsible for configuring navigationController either hidden or not with given parameters
  /// - Parameters:
  ///   - state: similar to isHidden
  ///   - animated: animated or not
  func setNavigationControllerHidden(to state: Bool, animated: Bool) {
    navigationController?.setNavigationBarHidden(state, animated: animated)
  }
  
}

//MARK:- Animations
extension RideSearchViewController {
  /// This method is user for configuring isHidden property of UIElements with given state
  /// - Parameter state: the state to set
  func setUIElementsHidden(to state: Bool) {
    dateView.isHidden = state
    bottomLine.isHidden = state
    topLine.isHidden = state
    passengersButton.isHidden = state
    tableViewSubview.isHidden = !state
  }
  
  /// This method is responsible for animating UITextField and its subview
  /// Calls constraint factory to create new constraints with given parameters
  /// - Parameter textField: the textField which calls this method (AKA sender)
  func animate(textField: UITextField) {
    switch textField {
    case departureTextField:
      view.setNeedsLayout()
      tableViewSubviewTopConstraint.isActive = false
      tableViewSubviewTopConstraint = controllerDataProvider.constraintFactory.makeConstraint(
        forAnimationState: .animated, animatingView: .tableViewSubview, tableSubviewTopAnchor: departureContentSubview)
      tableViewSubviewTopConstraint.isActive = true
      
      UIView.animate(withDuration: 0.3) {
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        self.tableViewSubview.alpha = 1.0
        self.view.layoutIfNeeded()
      }
      setUIElementsHidden(to: true)
      departureBackButton.isHidden = false
      destinationContentSubview.isHidden = true
      
    case destinationTextField:
      view.setNeedsLayout()
      destinationContentSubviewTopConstraint.isActive = false
      tableViewSubviewTopConstraint.isActive = false
      destinationTFTopConstraint.isActive = false
      
      destinationContentSubviewTopConstraint = controllerDataProvider.constraintFactory.makeConstraint(
        forAnimationState: .animated, animatingView: .toContentSubview, tableSubviewTopAnchor: destinationContentSubview)
      
      tableViewSubviewTopConstraint = controllerDataProvider.constraintFactory.makeConstraint(
        forAnimationState: .animated, animatingView: .tableViewSubview, tableSubviewTopAnchor: departureContentSubview)
      
      destinationTFTopConstraint = controllerDataProvider.constraintFactory.makeConstraint(
        forAnimationState: .animated, animatingView: .toTextField, tableSubviewTopAnchor: departureContentSubview)
      
      destinationContentSubviewTopConstraint.isActive = true
      tableViewSubviewTopConstraint.isActive = true
      destinationTFTopConstraint.isActive = true
      
      UIView.animate(withDuration: 0.3, delay: 0, options: [.curveEaseOut], animations: {
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        self.tableViewSubview.alpha = 1.0
        self.view.layoutIfNeeded()
      })
      setUIElementsHidden(to: true)
      departureContentSubview.isHidden = true
      destinationBackButton.isHidden = false
      
    default:
      break
    }
  }
  
  /// This method is responsible for dismissing animations of UITextField and its subview
  /// Calls constraint factory to create new constraints with given parameters
  /// - Parameter textField: the textField which calls this method (AKA sender)
  func dismissAnimation(textField: UITextField) {
    switch textField {
    case departureTextField:
      controllerDataProvider.departureTextFieldTapped = false
      tableViewSubviewTopConstraint.isActive = false
      tableViewSubviewTopConstraint = controllerDataProvider.constraintFactory.makeConstraint(
        forAnimationState: .dismissed, animatingView: .tableViewSubview, tableSubviewTopAnchor: view)
      
      UIView.animate(withDuration: 0.3) {
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        self.tableViewSubview.alpha = 0.0
        self.view.layoutIfNeeded()
      }
      
      tableViewSubviewTopConstraint.isActive = true
      setUIElementsHidden(to: false)
      departureBackButton.isHidden = true
      destinationContentSubview.isHidden = false
      
    case destinationTextField:
      controllerDataProvider.destinationTextFieldTapped = false
      view.setNeedsLayout()
      destinationContentSubviewTopConstraint.isActive = false
      destinationTFTopConstraint.isActive = false
      tableViewSubviewTopConstraint.isActive = false
      tableViewSubviewTopConstraint = controllerDataProvider.constraintFactory.makeConstraint(
        forAnimationState: .dismissed, animatingView: .tableViewSubview,tableSubviewTopAnchor: view)
      
      destinationContentSubviewTopConstraint = controllerDataProvider.constraintFactory.makeConstraint(
        forAnimationState: .dismissed, animatingView: .toContentSubview, tableSubviewTopAnchor:destinationContentSubview)
      
      destinationTFTopConstraint = controllerDataProvider.constraintFactory.makeConstraint(
        forAnimationState: .dismissed, animatingView: .toTextField, tableSubviewTopAnchor: destinationContentSubview)
      
      tableViewSubviewTopConstraint.isActive = true
      destinationContentSubviewTopConstraint.isActive = true
      destinationTFTopConstraint.isActive = true
      
      UIView.animate(withDuration: 0.3, delay: 0, options: [.curveEaseOut], animations: {
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        self.tableViewSubview.alpha = 0.0
        self.view.layoutIfNeeded()
      })
      setUIElementsHidden(to: false)
      departureContentSubview.isHidden = false
      destinationBackButton.isHidden = true
      
    default:
      break
    }
  }
}

