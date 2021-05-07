//
//  MainTripDataProviderTests.swift
//  RideInTests
//
//  Created by Алекс Ломовской on 28.04.2021.
//

import XCTest
import MapKit

@testable import RideIn

class MainTripDataManagerTests: XCTestCase {
    
    var sut: MainTripsDataManager!
    
    override func setUpWithError() throws {
        sut = MainTripsDataManager()
    }
    
    override func tearDownWithError() throws {
        sut = nil
    }
    
    //MARK: testDataDownloading-
    func testDataDownloading() throws {
        // given
        let fakeDepartureCoordinates = "46.668396,32.646142"
        let fakeDestinationCoordinates = "46.966541,32.000077"
        let fakeSeats = "2"
        let promise = expectation(description: "Data downloading ended")
        var responseError: Error?
        var responseTrips: [Trip]?
        
        // when
        sut.downloadDataWith(departureCoordinates: fakeDepartureCoordinates, destinationCoordinates: fakeDestinationCoordinates, seats: fakeSeats, date: nil) { result in
            switch result {
            case .failure(let error): responseError = error
            case .success(let trips): responseTrips = trips
            }
            promise.fulfill()
        }
        wait(for: [promise], timeout: 5)
        
        // then
        XCTAssertNil(responseError)
        XCTAssertNotNil(responseTrips)
    }
    
    //MARK: testDataPreparing -
    func testDataPreparing() throws {
        //given
        let lat = CLLocationDegrees(46.668396)
        let long = CLLocationDegrees(32.000077)
        let fakeUserLocation = CLLocation(latitude: lat, longitude: long)
        
        let fakePrice1 = Price(amount: "350", currency: "")
        let fakePrice2 = Price(amount: "400", currency: "")
        
        let fakeDeparturePlace1 = Place(city: "Kherson", address: "", latitude: 46.668396, longitude: 32.646142, countryCode: "")
        let fakeDestinationPlace1 = Place(city: "Odessa", address: "", latitude: 46.966541, longitude: 32.000077, countryCode: "")
        let fakeDepartureWaypoint1 = Waypoint(dateTime: "", place: fakeDeparturePlace1)
        let fakeDestinationWaypoint1 = Waypoint(dateTime: "", place: fakeDestinationPlace1)
        
        let fakeDeparturePlace2 = Place(city: "Kherson", address: "", latitude: 46.668396, longitude: 32.646142, countryCode: "")
        let fakeDestinationPlace2 = Place(city: "Odessa", address: "", latitude: 46.966541, longitude: 32.000077, countryCode: "")
        let fakeDepartureWaypoint2 = Waypoint(dateTime: "", place: fakeDeparturePlace2)
        let fakeDestinationWaypoint2 = Waypoint(dateTime: "", place: fakeDestinationPlace2)
        
        let fakeTrip1 = Trip(link: "fakeTrip1", waypoints: [fakeDepartureWaypoint1, fakeDestinationWaypoint1], price: fakePrice1, vehicle: nil, distanceInMeters: 3000)
        let fakeTrip2 = Trip(link: "fakeTrip2", waypoints: [fakeDepartureWaypoint2, fakeDestinationWaypoint2], price: fakePrice2, vehicle: nil, distanceInMeters: 3000)
        let trips = [fakeTrip1, fakeTrip2]
        
        let promise = expectation(description: "Data processed")
        var processingError: Error?
        var fakeUnsorted: [Trip]?
        var fakeCheapToTop: [Trip]?
        var fakeCheapToBottom: [Trip]?
        var fakeCheapest: Trip?
        
        // when
        do {
            try sut.prepareData(trips: trips, userLocation: fakeUserLocation) { unsorted, cheapToTop, cheapToBottom, cheapest, _ in
                fakeUnsorted = trips
                fakeCheapToTop = cheapToTop
                fakeCheapToBottom = cheapToBottom
                fakeCheapest = cheapest
                promise.fulfill()
            }
        } catch let error {
            processingError = error
            promise.fulfill()
        }
        wait(for: [promise], timeout: 5)
        
        // then
        XCTAssertNil(processingError)
        XCTAssertEqual(fakeUnsorted, trips)
        XCTAssertEqual(fakeCheapToTop!.first, fakeTrip1)
        XCTAssertEqual(fakeCheapToBottom!.first, fakeTrip2)
        XCTAssertEqual(fakeCheapest, fakeTrip1)
    }
    
    //MARK: testDataPreparingEmptyError -
    func testDataPreparingEmptyError() throws {
        // given
        let trips = [Trip]()
        let lat = CLLocationDegrees(46.668396)
        let long = CLLocationDegrees(32.000077)
        let dummyUserLocation = CLLocation(latitude: lat, longitude: long)
        let promise = expectation(description: "Data processing ended")
        var noTripsError: Error?
        
        // when
        do {
            try sut.prepareData(trips: trips, userLocation: dummyUserLocation, completion: { _, _, _, _, _ in })
            XCTFail()
        } catch let error {
            noTripsError = error
            promise.fulfill()
        }
        wait(for: [promise], timeout: 5)
        
        // then
        XCTAssertNotNil(noTripsError)
    }
}

