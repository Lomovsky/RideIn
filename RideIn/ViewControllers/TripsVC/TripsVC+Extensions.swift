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
    private func showTripVC(trip: Trip, date: String, passengersCount: Int, departmentPlace: String,
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

//MARK:- CollectionViewDataSource
extension TripsViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch collectionView {
        case recommendationsCollectionView: return trips.count == 1 ? 1 :  2
        case allTipsCollectionView: return trips.count
        case cheapTripsToTopCollectionView: return cheapTripsToTop.count
        case cheapTripsToBottomCollectionView: return cheapTripsToBottom.count
        default: return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        switch collectionView {
        case recommendationsCollectionView:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TripCollectionViewCell.recommendationsReuseIdentifier,
                                                          for: indexPath) as! TripCollectionViewCell
            cell.addShadow(color: .black, radius: 4, opacity: 0.1)
            guard trips.count != 1 else { cell.setPlaceholder(); return cell }
                
                let cheapestTripDepartureTimeString = dateTimeFormatter.getDateTime(format: .hhmmss, from: cheapestTrip, for: .department)
                let cheapestTripArrivingTimeString = dateTimeFormatter.getDateTime(format: .hhmmss, from: cheapestTrip, for: .destination)
                let closestTripDepartureTimeString = dateTimeFormatter.getDateTime(format: .hhmmss, from: closestTrip, for: .department)
                let closestTripArrivingTimeString = dateTimeFormatter.getDateTime(format: .hhmmss, from: closestTrip, for: .destination)

                if indexPath.row == 0 {
                    cell.configureTheCell(departurePlace: departurePlaceName,
                                          arrivingPlace: destinationPlaceName,
                                          departureTime: cheapestTripDepartureTimeString,
                                          arrivingTime: cheapestTripArrivingTimeString,
                                          filterType: NSLocalizedString("TheCheapestTrip", comment: ""),
                                          price: cheapestTrip?.price.amount ?? "")

                } else {
                    cell.configureTheCell(departurePlace: departurePlaceName,
                                          arrivingPlace: destinationPlaceName,
                                          departureTime: closestTripDepartureTimeString,
                                          arrivingTime: closestTripArrivingTimeString,
                                          filterType: NSLocalizedString("TheClosestTrip", comment: ""),
                                          price: closestTrip?.price.amount ?? "")
                }
            return cell
            
        case allTipsCollectionView:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TripCollectionViewCell.allTripsReuseIdentifier,
                                                          for: indexPath) as! TripCollectionViewCell
            cell.addShadow(color: .black, radius: 5, opacity: 0.4)
            let trip = trips[indexPath.row]
            let tripDepartureTime = dateTimeFormatter.getDateTime(format: .hhmmss, from: trip, for: .department)
            let tripArrivingTime = dateTimeFormatter.getDateTime(format: .hhmmss, from: trip, for: .destination)
            
            cell.configureTheCell(departurePlace: departurePlaceName,
                                  arrivingPlace: destinationPlaceName,
                                  departureTime: tripDepartureTime,
                                  arrivingTime: tripArrivingTime,
                                  filterType: nil,
                                  price: trip.price.amount)
            return cell
            
        case cheapTripsToTopCollectionView:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TripCollectionViewCell.cheapToTopReuseIdentifier,
                                                          for: indexPath) as! TripCollectionViewCell
            cell.addShadow(color: .black, radius: 5, opacity: 0.4)
            let trip = cheapTripsToTop[indexPath.row]
            let tripDepartureTime = dateTimeFormatter.getDateTime(format: .hhmmss, from: trip, for: .department)
            let tripArrivingTime = dateTimeFormatter.getDateTime(format: .hhmmss, from: trip, for: .destination)
            
            cell.configureTheCell(departurePlace: departurePlaceName,
                                  arrivingPlace: destinationPlaceName,
                                  departureTime: tripDepartureTime,
                                  arrivingTime: tripArrivingTime,
                                  filterType: nil,
                                  price: trip.price.amount)
            return cell
            
        case cheapTripsToBottomCollectionView:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TripCollectionViewCell.cheapToBottomReuseIdentifier,
                                                          for: indexPath) as! TripCollectionViewCell
            cell.addShadow(color: .black, radius: 5, opacity: 0.4)
            let trip = cheapTripsToBottom[indexPath.row]
            let tripDepartureTime = dateTimeFormatter.getDateTime(format: .hhmmss, from: trip, for: .department)
            let tripArrivingTime = dateTimeFormatter.getDateTime(format: .hhmmss, from: trip, for: .destination)
            
            cell.configureTheCell(departurePlace: departurePlaceName,
                                  arrivingPlace: destinationPlaceName,
                                  departureTime: tripDepartureTime,
                                  arrivingTime: tripArrivingTime,
                                  filterType: nil,
                                  price: trip.price.amount)
            return cell
            
        default: return UICollectionViewCell()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        switch collectionView {
        case recommendationsCollectionView:
            guard trips.count != 1 else { return }
            if indexPath.row == 0 {
                guard let trip = cheapestTrip else { return }
                let departmentTime = dateTimeFormatter.getDateTime(format: .hhmmss, from: trip, for: .department)
                let arrivingTime = dateTimeFormatter.getDateTime(format: .hhmmss, from: trip, for: .destination)
                let price = Float(trip.price.amount)
                showTripVC(trip: trip, date: date, passengersCount: numberOfPassengers, departmentPlace: departurePlaceName,
                           departmentTime: departmentTime, arrivingPlace: destinationPlaceName,
                           arrivingTime: arrivingTime, price: price ?? 0)
            } else {
                guard let trip = closestTrip else { return }
                let departmentTime = dateTimeFormatter.getDateTime(format: .hhmmss, from: trip, for: .department)
                let arrivingTime = dateTimeFormatter.getDateTime(format: .hhmmss, from: trip, for: .destination)
                let price = Float(trip.price.amount)
                showTripVC(trip: trip, date: date, passengersCount: numberOfPassengers, departmentPlace: departurePlaceName,
                           departmentTime: departmentTime, arrivingPlace: destinationPlaceName,
                           arrivingTime: arrivingTime, price: price ?? 0)
            }
            
        case allTipsCollectionView:
            let trip = trips[indexPath.row]
            let departmentTime = dateTimeFormatter.getDateTime(format: .hhmmss, from: trip, for: .department)
            let arrivingTime = dateTimeFormatter.getDateTime(format: .hhmmss, from: trip, for: .destination)
            let price = Float(trip.price.amount)
            showTripVC(trip: trip, date: date, passengersCount: numberOfPassengers, departmentPlace: departurePlaceName,
                       departmentTime: departmentTime, arrivingPlace: destinationPlaceName,
                       arrivingTime: arrivingTime, price: price ?? 0)
            
        case cheapTripsToTopCollectionView:
            let trip = cheapTripsToTop[indexPath.row]
            let departmentTime = dateTimeFormatter.getDateTime(format: .hhmmss, from: trip, for: .department)
            let arrivingTime = dateTimeFormatter.getDateTime(format: .hhmmss, from: trip, for: .destination)
            let price = Float(trip.price.amount)
            showTripVC(trip: trip, date: date, passengersCount: numberOfPassengers, departmentPlace: departurePlaceName,
                       departmentTime: departmentTime, arrivingPlace: destinationPlaceName,
                       arrivingTime: arrivingTime, price: price ?? 0)
            
        case cheapTripsToBottomCollectionView:
            let trip = cheapTripsToBottom[indexPath.row]
            let departmentTime = dateTimeFormatter.getDateTime(format: .hhmmss, from: trip, for: .department)
            let arrivingTime = dateTimeFormatter.getDateTime(format: .hhmmss, from: trip, for: .destination)
            let price = Float(trip.price.amount)
            showTripVC(trip: trip, date: date, passengersCount: numberOfPassengers, departmentPlace: departurePlaceName,
                       departmentTime: departmentTime, arrivingPlace: destinationPlaceName,
                       arrivingTime: arrivingTime, price: price ?? 0)
            
        default: break
        }
    }
}

//MARK:- CollectionViewDelegateFlowLayout
extension TripsViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let height = collectionView.frame.size.height * 0.9
        let width = collectionView.frame.size.width * 0.8
        let oneCardWidth = collectionView.frame.size.width * 0.9
        let pageScrollViewCellSize = CGSize(width: pageScrollView.frame.size.width * 0.9,
                              height: pageScrollSubview.frame.size.height * 0.4)
        
        switch collectionView {
        case recommendationsCollectionView: return trips.count == 1 ? CGSize(width: oneCardWidth, height: height) : CGSize(width: width, height: height)
        case allTipsCollectionView: return pageScrollViewCellSize
        case cheapTripsToTopCollectionView: return pageScrollViewCellSize
        case cheapTripsToBottomCollectionView: return pageScrollViewCellSize
        default: return CGSize()
        }
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

