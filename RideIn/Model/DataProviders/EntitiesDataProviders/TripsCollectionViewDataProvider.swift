//
//  MainTripsCollectionViewDataProvider.swift
//  RideIn
//
//  Created by Алекс Ломовской on 05.05.2021.
//

import UIKit

final class MainTripsCollectionViewDataProvider: NSObject, TripsCollectionViewDataProvider {
    
    //MARK: Declarations -
    
    /// Parent viewController that asks for data
    weak var parentVC: UIViewController?
    
    var delegate: MainTripsCollectionViewDataProviderDelegate?
    
    /// The name of the departure place
    var departurePlaceName = String()
    
    /// The name of destination place
    var destinationPlaceName = String()
    
    /// The base unsorted array of available trips
    var trips = [Trip]()
    
    /// The sorted array of available trips with increasing price
    var cheapTripsToTop = [Trip]()
    
    /// The sorted array of available trips with decreasing price
    var cheapTripsToBottom = [Trip]()
    
    /// The cheapest trip
    var cheapestTrip: Trip?
    
    /// The closest to user departure  point trip
    var closestTrip: Trip?
    
    /// Number of passengers
    var numberOfPassengers = Int()
    
    /// The selected trip departure date
    var date = NSLocalizedString("Date", comment: "")
    
    //MARK: number of rows in section
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let vc = parentVC as? TripsViewController else { return 0 }
        switch collectionView {
        case vc.recommendationsCollectionView: return trips.count == 1 ? 1 :  2
            
        case vc.allTipsCollectionView: return trips.count
            
        case vc.cheapTripsToTopCollectionView: return cheapTripsToTop.count
            
        case vc.cheapTripsToBottomCollectionView: return cheapTripsToBottom.count
            
        default: return 0
        }
    }
    
    //MARK: cellForItemAt
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let vc = parentVC as? TripsViewController else { return UICollectionViewCell() }
        switch collectionView {
        case vc.recommendationsCollectionView:
            let cell: TripCollectionViewCell = collectionView.dequeueReusableCell(for: indexPath)
            cell.addShadow(color: .black, radius: 4, opacity: 0.1)
            guard trips.count != 1 else { cell.setPlaceholder(); return cell }
            
            let cheapestTripDepartureTimeString = MainDateTimeFormatter().getDateTime(format: .hhmmss, from: cheapestTrip, for: .department)
            let cheapestTripArrivingTimeString = MainDateTimeFormatter().getDateTime(format: .hhmmss, from: cheapestTrip, for: .destination)
            let closestTripDepartureTimeString = MainDateTimeFormatter().getDateTime(format: .hhmmss, from: closestTrip, for: .department)
            let closestTripArrivingTimeString = MainDateTimeFormatter().getDateTime(format: .hhmmss, from: closestTrip, for: .destination)
            
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
            
        case vc.allTipsCollectionView:
            let cell: TripCollectionViewCell = collectionView.dequeueReusableCell(for: indexPath)
            cell.addShadow(color: .black, radius: 5, opacity: 0.4)
            let trip = trips[indexPath.row]
            let tripDepartureTime = MainDateTimeFormatter().getDateTime(format: .hhmmss, from: trip, for: .department)
            let tripArrivingTime = MainDateTimeFormatter().getDateTime(format: .hhmmss, from: trip, for: .destination)
            
            cell.configureTheCell(departurePlace: departurePlaceName,
                                  arrivingPlace: destinationPlaceName,
                                  departureTime: tripDepartureTime,
                                  arrivingTime: tripArrivingTime,
                                  filterType: nil,
                                  price: trip.price.amount)
            return cell
            
        case vc.cheapTripsToTopCollectionView:
            let cell: TripCollectionViewCell = collectionView.dequeueReusableCell(for: indexPath)
            cell.addShadow(color: .black, radius: 5, opacity: 0.4)
            let trip = cheapTripsToTop[indexPath.row]
            let tripDepartureTime = MainDateTimeFormatter().getDateTime(format: .hhmmss, from: trip, for: .department)
            let tripArrivingTime = MainDateTimeFormatter().getDateTime(format: .hhmmss, from: trip, for: .destination)
            
            cell.configureTheCell(departurePlace: departurePlaceName,
                                  arrivingPlace: destinationPlaceName,
                                  departureTime: tripDepartureTime,
                                  arrivingTime: tripArrivingTime,
                                  filterType: nil,
                                  price: trip.price.amount)
            return cell
            
        case vc.cheapTripsToBottomCollectionView:
            let cell: TripCollectionViewCell = collectionView.dequeueReusableCell(for: indexPath)
            cell.addShadow(color: .black, radius: 5, opacity: 0.4)
            let trip = cheapTripsToBottom[indexPath.row]
            let tripDepartureTime = MainDateTimeFormatter().getDateTime(format: .hhmmss, from: trip, for: .department)
            let tripArrivingTime = MainDateTimeFormatter().getDateTime(format: .hhmmss, from: trip, for: .destination)
            
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
    
    //MARK: didSelectItemAt -
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let vc = parentVC as? TripsViewController else { return }
        
        switch collectionView {
        case vc.recommendationsCollectionView:
            guard trips.count != 1 else { return }
            if indexPath.row == 0 {
                guard let trip = cheapestTrip else { return }
                let departmentTime = MainDateTimeFormatter().getDateTime(format: .hhmmss, from: trip, for: .department)
                let arrivingTime = MainDateTimeFormatter().getDateTime(format: .hhmmss, from: trip, for: .destination)
                let price = Float(trip.price.amount)
                let preparedData = PreparedTripsDataModelFromTripsVC(selectedTrip: trip, date: date,
                                                             passengersCount: numberOfPassengers, departurePlace: departurePlaceName,
                                                             destinationPlace: destinationPlaceName, departureTime: departmentTime,
                                                             arrivingTime: arrivingTime, price: price ?? 0)
                vc.onCellSelected?(preparedData)
                
            } else {
                guard let trip = closestTrip else { return }
                let departmentTime = MainDateTimeFormatter().getDateTime(format: .hhmmss, from: trip, for: .department)
                let arrivingTime = MainDateTimeFormatter().getDateTime(format: .hhmmss, from: trip, for: .destination)
                let price = Float(trip.price.amount)
                let preparedData = PreparedTripsDataModelFromTripsVC(selectedTrip: trip, date: date,
                                                             passengersCount: numberOfPassengers, departurePlace: departurePlaceName,
                                                             destinationPlace: destinationPlaceName, departureTime: departmentTime,
                                                             arrivingTime: arrivingTime, price: price ?? 0)
                vc.onCellSelected?(preparedData)
            }
            
        case vc.allTipsCollectionView:
            let trip = trips[indexPath.row]
            let departmentTime = MainDateTimeFormatter().getDateTime(format: .hhmmss, from: trip, for: .department)
            let arrivingTime = MainDateTimeFormatter().getDateTime(format: .hhmmss, from: trip, for: .destination)
            let price = Float(trip.price.amount)
            let preparedData = PreparedTripsDataModelFromTripsVC(selectedTrip: trip, date: date,
                                                         passengersCount: numberOfPassengers, departurePlace: departurePlaceName,
                                                         destinationPlace: destinationPlaceName, departureTime: departmentTime,
                                                         arrivingTime: arrivingTime, price: price ?? 0)
            vc.onCellSelected?(preparedData)
            
            
        case vc.cheapTripsToTopCollectionView:
            let trip = cheapTripsToTop[indexPath.row]
            let departmentTime = MainDateTimeFormatter().getDateTime(format: .hhmmss, from: trip, for: .department)
            let arrivingTime = MainDateTimeFormatter().getDateTime(format: .hhmmss, from: trip, for: .destination)
            let price = Float(trip.price.amount)
            let preparedData = PreparedTripsDataModelFromTripsVC(selectedTrip: trip, date: date,
                                                         passengersCount: numberOfPassengers, departurePlace: departurePlaceName,
                                                         destinationPlace: destinationPlaceName, departureTime: departmentTime,
                                                         arrivingTime: arrivingTime, price: price ?? 0)
            vc.onCellSelected?(preparedData)
            
            
        case vc.cheapTripsToBottomCollectionView:
            let trip = cheapTripsToBottom[indexPath.row]
            let departmentTime = MainDateTimeFormatter().getDateTime(format: .hhmmss, from: trip, for: .department)
            let arrivingTime = MainDateTimeFormatter().getDateTime(format: .hhmmss, from: trip, for: .destination)
            let price = Float(trip.price.amount)
            let preparedData = PreparedTripsDataModelFromTripsVC(selectedTrip: trip, date: date,
                                                         passengersCount: numberOfPassengers, departurePlace: departurePlaceName,
                                                         destinationPlace: destinationPlaceName, departureTime: departmentTime,
                                                         arrivingTime: arrivingTime, price: price ?? 0)
            vc.onCellSelected?(preparedData)
            
            
        default: break
        }
    }
    
    
    deinit {
        Log.i("Deallocation \(self)")
    }
}

//MARK: UICollectionViewDelegateFlowLayout
extension MainTripsCollectionViewDataProvider: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        guard let vc = parentVC as? TripsViewController else { return CGSize() }
        let height = collectionView.frame.size.height * 0.9
        let width = collectionView.frame.size.width * 0.8
        let oneCardWidth = collectionView.frame.size.width * 0.9
        let pageScrollViewCellSize = CGSize(width: vc.pageScrollView.frame.size.width * 0.9,
                                            height: vc.pageScrollSubview.frame.size.height * 0.4)
        
        switch collectionView {
        case vc.recommendationsCollectionView: return trips.count == 1 ?
            CGSize(width: oneCardWidth, height: height) : CGSize(width: width, height: height)
            
        case vc.allTipsCollectionView: return pageScrollViewCellSize
            
        case vc.cheapTripsToTopCollectionView: return pageScrollViewCellSize
            
        case vc.cheapTripsToBottomCollectionView: return pageScrollViewCellSize
            
        default: return CGSize()
        }
    }
}
