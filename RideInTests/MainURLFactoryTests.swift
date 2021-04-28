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
    
    override func setUpWithError() throws {
        sut = MainURLFactory()
    }

    override func tearDownWithError() throws {
        sut = nil
    }

    func testMakeUrlWithoutDate() throws {
        // given
        let fromCoordinates = "46.668396,32.646142"
        let toCoordinates = "46.966541,32.000077"
        let seats = "3"
        let url: URL?
        
        // when
        sut.setCoordinates(coordinates: fromCoordinates, place: .department)
        sut.setCoordinates(coordinates: toCoordinates, place: .destination)
        sut.setSeats(seats: seats)
        sut.setDate(date: nil)
        url = sut.makeURL()
        
        // then
        XCTAssertNotNil(url)
        
    }
    
    func testMakeUrlWithDate() throws {
        // given
        let fromCoordinates = "46.668396,32.646142"
        let toCoordinates = "46.966541,32.000077"
        let seats = "3"
        let date = "2021-01-01T00:00:00"
        let url: URL?
        
        // when
        sut.setCoordinates(coordinates: fromCoordinates, place: .department)
        sut.setCoordinates(coordinates: toCoordinates, place: .destination)
        sut.setSeats(seats: seats)
        sut.setDate(date: date)
        url = sut.makeURL()
        
        // then
        XCTAssertNotNil(url)
    }
}
