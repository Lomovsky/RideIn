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

    var dateTimeFormatter: DateTimeFormatter!
    var tripMOC: Trip!
    var waypontMOC: Waypoint!
    var destinationWaypontMOC: Waypoint!
    var placeMOC: Place!
    var priceMOC: Price!
    
    override func setUpWithError() throws {
        dateTimeFormatter = MainDateTimeFormatter()
        placeMOC = Place(city: "Kherson", address: "Kherson", latitude: 46.668396, longitude: 32.646142, countryCode: "0")
        waypontMOC = Waypoint(dateTime: "2020-11-01T12:35:00", place: placeMOC)
        destinationWaypontMOC = Waypoint(dateTime: "2020-11-01T23:00:00", place: placeMOC)
        priceMOC = Price(amount: "2222", currency: "UAH")
        tripMOC = Trip(link: "", waypoints: [waypontMOC, destinationWaypontMOC], price: priceMOC, vehicle: nil, distanceInMeters: 2000)

        try super.setUpWithError()
    }

    override func tearDownWithError() throws {
        dateTimeFormatter = nil
        tripMOC = nil
        priceMOC = nil
        waypontMOC = nil
        placeMOC = nil
        try super.tearDownWithError()
    }

    //MARK:- Get department time test
    func testGetTime() throws {
        // given
        let time = dateTimeFormatter.getDateTime(format: .hhmmss, from: tripMOC, for: .department)
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
        let date = dateTimeFormatter.getDateTime(format: .dddmmyy, from: tripMOC, for: .department)
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
        let time = dateTimeFormatter.getDateTime(format: .hhmmss, from: tripMOC, for: .destination)
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
        let date = dateTimeFormatter.getDateTime(format: .dddmmyy, from: tripMOC, for: .destination)
        let regex = try! NSRegularExpression(pattern: "[0-9]{4}-[0-9]{2}-[0-9]{2}")
        let range = NSRange(location: 0, length: date.utf16.count)
        
        //when
        let dateCheck = regex.firstMatch(in: date, options: [], range: range)
        
        //then
        XCTAssertNotNil(dateCheck)
    }

}
