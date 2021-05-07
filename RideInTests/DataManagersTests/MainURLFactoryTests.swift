//
//  MainURLFactoryTests.swift
//  RideInTests
//
//  Created by Алекс Ломовской on 28.04.2021.
//

import XCTest
@testable import RideIn

class MainURLFactoryTests: XCTestCase {
    
    var sut: MainURLFactory!
    var fakeFromCoordinates: String!
    var fakeToCoordinates: String!
    var fakeSeats: String!
    var fakeDate: String!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        sut = MainURLFactory()
        fakeFromCoordinates = "46.668396,32.646142"
        fakeToCoordinates = "46.966541,32.000077"
        fakeSeats = "3"
        fakeDate = "2021-01-01T00:00:00"
    }
    
    override func tearDownWithError() throws {
        sut = nil
        fakeFromCoordinates = nil
        fakeToCoordinates = nil
        fakeSeats = nil
        fakeDate = nil
        try super.tearDownWithError()
    }
    
    func testMakeUrlWithoutDate() throws {
        // given
        let url: URL?
        
        // when
        sut.setCoordinates(coordinates: fakeFromCoordinates, place: .department)
        sut.setCoordinates(coordinates: fakeToCoordinates, place: .destination)
        sut.setSeats(seats: fakeSeats)
        sut.setDate(date: nil)
        url = sut.makeURL()
        
        // then
        XCTAssertNotNil(url)
        
    }
    
    func testMakeUrlWithDate() throws {
        // given
        let url: URL?
        
        // when
        sut.setCoordinates(coordinates: fakeFromCoordinates, place: .department)
        sut.setCoordinates(coordinates: fakeToCoordinates, place: .destination)
        sut.setSeats(seats: fakeSeats)
        sut.setDate(date: fakeDate)
        url = sut.makeURL()
        
        // then
        XCTAssertNotNil(url)
    }
}
