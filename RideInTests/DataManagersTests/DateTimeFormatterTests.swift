//
//  DateTimeFormatterTests.swift
//  RideInTests
//
//  Created by Алекс Ломовской on 26.04.2021.
//

import XCTest
@testable import RideIn
//MARK:- DateTimeFormatter tests
class DateTimeFormatterTests: XCTestCase {

    var sut: DateTimeFormatter!
    var fakeTrip: Trip!
    var fakeWaypont: Waypoint!
    var fakeDestinationWaypont: Waypoint!
    var fakePlace: Place!
    var fakePrice: Price!
    
    override func setUpWithError() throws {
        sut = MainDateTimeFormatter()
        fakePlace = Place(city: "Kherson", address: "Kherson", latitude: 46.668396, longitude: 32.646142, countryCode: "0")
        fakeWaypont = Waypoint(dateTime: "2020-11-01T12:35:00", place: fakePlace)
        fakeDestinationWaypont = Waypoint(dateTime: "2020-11-01T23:00:00", place: fakePlace)
        fakePrice = Price(amount: "2222", currency: "UAH")
        fakeTrip = Trip(link: "", waypoints: [fakeWaypont, fakeDestinationWaypont], price: fakePrice, vehicle: nil, distanceInMeters: 2000)

        try super.setUpWithError()
    }

    override func tearDownWithError() throws {
        sut = nil
        fakeTrip = nil
        fakePrice = nil
        fakeWaypont = nil
        fakePlace = nil
        try super.tearDownWithError()
    }

    //MARK:- Get department time test
    func testGetTime() throws {
        // given
        let time = sut.getDateTime(format: .hhmmss, from: fakeTrip, for: .department)
        let regex = try! NSRegularExpression(pattern: "[0-9]{2}:[0-9]{2}")
        let range = NSRange(location: 0, length: time.utf16.count)
        
        // when
        let timeCheck = regex.firstMatch(in: time, options: [], range: range)
        
        //then
        XCTAssertNotNil(timeCheck)
    }
    
    //MARK:- Get department date test
    func testGetDate() throws {
        //given
        let date = sut.getDateTime(format: .dddmmyy, from: fakeTrip, for: .department)
        let regex = try! NSRegularExpression(pattern: "[0-9]{4}-[0-9]{2}-[0-9]{2}")
        let range = NSRange(location: 0, length: date.utf16.count)
        
        //when
        let dateCheck = regex.firstMatch(in: date, options: [], range: range)
        
        //then
        XCTAssertNotNil(dateCheck)
    }
   
    //MARK:- Get destination time test
    func testGetTimeDestination() throws {
        // given
        let time = sut.getDateTime(format: .hhmmss, from: fakeTrip, for: .destination)
        let regex = try! NSRegularExpression(pattern: "[0-9]{2}:[0-9]{2}")
        let range = NSRange(location: 0, length: time.utf16.count)
        
        // when
        let timeCheck = regex.firstMatch(in: time, options: [], range: range)
        
        //then
        XCTAssertNotNil(timeCheck)
    }
    
    //MARK:- Get destination date test
    func testGetDateDestination() throws {
        //given
        let date = sut.getDateTime(format: .dddmmyy, from: fakeTrip, for: .destination)
        let regex = try! NSRegularExpression(pattern: "[0-9]{4}-[0-9]{2}-[0-9]{2}")
        let range = NSRange(location: 0, length: date.utf16.count)
        
        //when
        let dateCheck = regex.firstMatch(in: date, options: [], range: range)
        
        //then
        XCTAssertNotNil(dateCheck)
    }

}
