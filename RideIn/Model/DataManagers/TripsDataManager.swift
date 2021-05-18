//
//  MainTripsDataManager.swift
//  RideIn
//
//  Created by Алекс Ломовской on 05.05.2021.
//

import UIKit
import MapKit

protocol TripsDataManager {
  func downloadDataWith(departureCoordinates: String, destinationCoordinates: String, seats: String, date: String?,
                        completion: @escaping (Result<[Trip], Error>) -> Void)
  func prepareData(trips: [Trip], userLocation: CLLocation, completion: @escaping (_ unsortedTrips: [Trip], _ cheapToTop: [Trip],
                                                                                   _ cheapToBottom: [Trip], _ cheapestTrip: Trip?,
                                                                                   _ closestTrip: Trip?) -> Void) throws
}

//MARK:- MainTripsDataManager
final class MainTripsDataManager: TripsDataManager {
  
  /// This works with URLFactory and network manager to download data with the given coordinates and additional optional data
  /// - Parameters:
  ///   - departureCoordinates: departureCoordinates
  ///   - destinationCoordinates: destinationCoordinates
  ///   - seats: number of seats
  ///   - date: departure date
  ///   - completion: completion handler to process the data
  func downloadDataWith(departureCoordinates: String, destinationCoordinates: String,
                        seats: String, date: String?, completion: @escaping (Result<[Trip], Error>) -> Void)  {
    let urlFactory: URLFactory = MainURLFactory()
    let networkManager: NetworkManager = MainNetworkManager()
    urlFactory.setCoordinates(coordinates: departureCoordinates, place: .department)
    urlFactory.setCoordinates(coordinates: destinationCoordinates, place: .destination)
    urlFactory.setSeats(seats: seats)
    if date != nil { urlFactory.setDate(date: date!) }
    
    guard let url = urlFactory.makeURL() else { let error = NetworkManagerErrors.unableToMakeURL; completion(.failure(error)); return }
    networkManager.downloadData(withURL: url, decodeBy: Trips.self) { (result) in
      switch result {
      case .failure(let error): completion(.failure(error))
        
      case .success(let decodedData): completion(.success(decodedData.trips))
      }
    }
  }
  
  /// This method is responsible for preparing trips array to be presented on TripsVC
  /// - Parameters:
  ///   - trips: unsorted trips array
  ///   - userLocation: users current location or the location the user set on mapView
  ///   - completion: completionHandler to work with prepared data
  /// - Throws: if there will be zero trips in array (e.g. no trips available for some city ), the method will throw an error, which we can use to display warning etc.
  func prepareData(trips: [Trip],
                   userLocation: CLLocation,
                   completion: @escaping (_ unsortedTrips: [Trip],
                                          _ cheapToTop: [Trip],
                                          _ cheapToBottom: [Trip],
                                          _ cheapestTrip: Trip?,
                                          _ closestTrip: Trip?
                   ) -> Void) throws {
    guard !(trips.isEmpty) else { let error = NetworkManagerErrors.noTrips; throw error }
    let distanceCalculator: DistanceCalculator = MainDistanceCalculator()
    
    let unsortedTrips = trips
    let cheapToBottom = trips.sorted(by: { Float($0.price.amount) ?? 0 > Float($1.price.amount) ?? 0  })
    let cheapToTop = trips.sorted(by: { Float($0.price.amount) ?? 0 < Float($1.price.amount) ?? 0  })
    let cheapestTrip = cheapToTop.first
    let closestTrip = trips.sorted(by: { (trip1, trip2) -> Bool in
      
      let trip1Coordinates = CLLocation(latitude: trip1.waypoints.first!.place.latitude,
                                        longitude: trip1.waypoints.first!.place.longitude)
      let trip2Coordinates = CLLocation(latitude: trip2.waypoints.first!.place.latitude,
                                        longitude: trip2.waypoints.first!.place.longitude)
      let distance1 = distanceCalculator.getDistanceBetween(userLocation: userLocation,
                                                            departurePoint: trip1Coordinates)
      let distance2 = distanceCalculator.getDistanceBetween(userLocation: userLocation,
                                                            departurePoint: trip2Coordinates)
      
      return distanceCalculator.compareDistances(first: distance1, second: distance2)
    }).first
    
    completion(unsortedTrips, cheapToTop, cheapToBottom, cheapestTrip, closestTrip)
  }
  
  deinit {
    Log.i("deallocating \(self)")
  }
}
