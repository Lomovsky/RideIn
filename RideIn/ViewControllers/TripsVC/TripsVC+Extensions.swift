//
//  TripsVC+Extensions.swift
//  RideIn
//
//  Created by Алекс Ломовской on 20.04.2021.
//

import UIKit

//MARK:- HelpingMethods
extension TripsViewController {
    
    @objc final func goBack() {
        rideSearchDelegate?.setNavigationControllerHidden(to: false, animated: false)
        navigationController?.popViewController(animated: true)
    }
    
    @objc final func segmentedControlHandler(sender: UISegmentedControl) {
        pageScrollView.scrollTo(horizontalPage: sender.selectedSegmentIndex, numberOfPages: 3, animated: true)
    }
    
    func setCellShadow(for cell: UICollectionViewCell, color: UIColor, radius: CGFloat, opacity: Float) {
        cell.layer.shadowColor = color.cgColor
        cell.layer.shadowRadius = radius
        cell.layer.shadowOpacity = opacity
        cell.layer.shadowOffset = CGSize.init(width: 2.5, height: 2.5)
        cell.layer.masksToBounds = false
        cell.layer.shadowPath = UIBezierPath(rect: cell.bounds).cgPath
        cell.backgroundColor = .clear
    }

}

//MARK:- CollectionViewDataSource
extension TripsViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch collectionView {
        case recommendationsCollectionView: return 2
        case allTipsCollectionView: return trips.count
        case cheapTripsToTopCollectionView: return cheapTripsToTop.count
        case cheapTripsToBottomCollectionView: return cheapTripsToBottom.count
        default: return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TripCollectionViewCell.reuseIdentifier,
                                                      for: indexPath) as! TripCollectionViewCell
        
        switch collectionView {
        case recommendationsCollectionView:
            setCellShadow(for: cell, color: .black, radius: 4, opacity: 0.1)
            
            let cheapestTripDepartureTimeString = DateTimeManager().getDateTime(format: .hhmmss, from: cheapestTrip, for: .from)
            let cheapestTripArrivingTimeString = DateTimeManager().getDateTime(format: .hhmmss, from: cheapestTrip, for: .to)
            
            let closestTripDepartureTimeString = DateTimeManager().getDateTime(format: .hhmmss, from: closestTrip, for: .from)
            let closestTripArrivingTimeString = DateTimeManager().getDateTime(format: .hhmmss, from: closestTrip, for: .to)
            
            if indexPath.row == 0 {
                cell.configureTheCell(departurePlace: departurePlaceName,
                                      arrivingPlace: arrivingPlaceName,
                                      departureTime: cheapestTripDepartureTimeString,
                                      arrivingTime: cheapestTripArrivingTimeString,
                                      filterType: "Дешевле всего",
                                      price: cheapestTrip?.price.amount ?? "")
                
            } else {
                cell.configureTheCell(departurePlace: departurePlaceName,
                                      arrivingPlace: arrivingPlaceName,
                                      departureTime: closestTripDepartureTimeString,
                                      arrivingTime: closestTripArrivingTimeString,
                                      filterType: "Быстрее всего",
                                      price: closestTrip?.price.amount ?? "")
            }

        case allTipsCollectionView:
            setCellShadow(for: cell, color: .black, radius: 5, opacity: 0.4)
            let trip = trips[indexPath.row]
            let tripDepartureTime = DateTimeManager().getDateTime(format: .hhmmss, from: trip, for: .from)
            let tripArrivingTime = DateTimeManager().getDateTime(format: .hhmmss, from: trip, for: .to)
            
            cell.configureTheCell(departurePlace: departurePlaceName,
                                  arrivingPlace: arrivingPlaceName,
                                  departureTime: tripDepartureTime,
                                  arrivingTime: tripArrivingTime,
                                  filterType: nil,
                                  price: trip.price.amount)
            
        case cheapTripsToTopCollectionView:
            setCellShadow(for: cell, color: .black, radius: 5, opacity: 0.4)
            let trip = cheapTripsToTop[indexPath.row]
            let tripDepartureTime = DateTimeManager().getDateTime(format: .hhmmss, from: trip, for: .from)
            let tripArrivingTime = DateTimeManager().getDateTime(format: .hhmmss, from: trip, for: .to)
            
            cell.configureTheCell(departurePlace: departurePlaceName,
                                  arrivingPlace: arrivingPlaceName,
                                  departureTime: tripDepartureTime,
                                  arrivingTime: tripArrivingTime,
                                  filterType: nil,
                                  price: trip.price.amount)
            
        case cheapTripsToBottomCollectionView:
            setCellShadow(for: cell, color: .black, radius: 5, opacity: 0.4)
            let trip = cheapTripsToBottom[indexPath.row]
            let tripDepartureTime = DateTimeManager().getDateTime(format: .hhmmss, from: trip, for: .from)
            let tripArrivingTime = DateTimeManager().getDateTime(format: .hhmmss, from: trip, for: .to)
            
            cell.configureTheCell(departurePlace: departurePlaceName,
                                  arrivingPlace: arrivingPlaceName,
                                  departureTime: tripDepartureTime,
                                  arrivingTime: tripArrivingTime,
                                  filterType: nil,
                                  price: trip.price.amount)
            
        default:
            break
            
        }
        return cell
    }
    
}

//MARK:- CollectionViewDelegateFlowLayout
extension TripsViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let height = collectionView.frame.size.height * 0.9
        let width = collectionView.frame.size.width * 0.8
        
        let pageViewHeight = pageScrollSubview.frame.size.height * 0.4
        let pageViewWidth = pageScrollView.frame.size.width * 0.9
        
        switch collectionView {
        case recommendationsCollectionView: return CGSize(width: width, height: height)
            
        case allTipsCollectionView: return CGSize(width: pageViewWidth, height: pageViewHeight)
            
        case cheapTripsToTopCollectionView: return CGSize(width: pageViewWidth, height: pageViewHeight)
            
        case cheapTripsToBottomCollectionView: return CGSize(width: pageViewWidth, height: pageViewHeight)
            
        default: return CGSize()
        }
    }
}

//MARK:- ScrollViewDelegate
extension TripsViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        switch scrollView {
        case pageScrollView:
            pagesSegmentedControl.selectedSegmentIndex = Int(round(scrollView.contentOffset.x / view.frame.width))
        
        default: break
        }
    }
}

