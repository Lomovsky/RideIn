//
//  TripsVC+Extensions.swift
//  RideIn
//
//  Created by Алекс Ломовской on 20.04.2021.
//

import UIKit

//MARK:- HelpingMethods
extension TripsViewController {
    
    /// This method is called then user press back button
    @objc final func backButtonPressed() {
        rideSearchDelegate?.setNavigationControllerHidden(to: false, animated: false)
        navigationController?.popViewController(animated: true)
    }
    
    /// This method is responsible for scrolling to selected page
    /// - Parameter sender: UISegmentedControl that called this method
    @objc final func segmentedControlHandler(sender: UISegmentedControl) {
        pageScrollView.scrollTo(horizontalPage: sender.selectedSegmentIndex, numberOfPages: 3, animated: true)
    }
    
    /// This method is responsible for pushing SelectedTripVC with given data
    /// - Parameters:
    ///   - trip: the trip object to pass to SelectedTripVC
    ///   - date: current date
    ///   - passengersCount: number of passengers
    ///   - departmentPlace: departure place
    ///   - departmentTime: departure time
    ///   - arrivingPlace: destination place
    ///   - arrivingTime: destination time
    ///   - price: price of the trip
    func showTripVC(trip: Trip, date: String, passengersCount: Int, departmentPlace: String,
                            departmentTime: String, arrivingPlace: String,
                            arrivingTime: String, price: Float) {
        let vc = SelectedTripViewController()
        vc.date = date
        vc.departurePlace = departmentPlace
        vc.departureTime = departmentTime
        vc.destinationPlace = arrivingPlace
        vc.arrivingTime = arrivingTime
        vc.passengersCount = passengersCount
        vc.priceForOne = price
        vc.selectedTrip = trip
        navigationController?.pushViewController(vc, animated: true)
    }
    
}

//MARK:- ScrollViewDelegate
extension TripsViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        switch scrollView {
        case pageScrollView: pagesSegmentedControl.selectedSegmentIndex = Int(round(scrollView.contentOffset.x / view.frame.width))
            
        default: break
        }
    }
}

