//
//  RideSearchTableViewDataProviderTests.swift
//  RideInTests
//
//  Created by Алекс Ломовской on 29.04.2021.
//

import XCTest
import MapKit
@testable import RideIn

class RideSearchTableViewDataProviderTests: XCTestCase {
    
    var sut: RideSearchTableviewDataProvider!
    var delegateMock: RideSearchTableViewDataProviderDelegateMock!
    var tableView: UITableView!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        sut = RideSearchTableviewDataProvider()
        delegateMock = RideSearchTableViewDataProviderDelegateMock()
        sut.delegate = delegateMock
        tableView = UITableView()
        tableView.register(RideSearchTableViewCell.self, forCellReuseIdentifier: RideSearchTableViewCell.reuseIdentifier)
        tableView.delegate = sut
        tableView.dataSource = sut
        
        let lat1 = CLLocationDegrees(46.668396)
        let long1 = CLLocationDegrees(32.646142)
        let fakeCoordinates1 = CLLocationCoordinate2D(latitude: lat1, longitude: long1)
        let fakePlaceMark1 = MKPlacemark(coordinate: fakeCoordinates1)
        let fakeItem1 = MKMapItem(placemark: fakePlaceMark1)
        fakeItem1.name = "Kherson"
        
        let lat2 = CLLocationDegrees(46.966541)
        let long2 = CLLocationDegrees(32.000077)
        let fakeCoordinates2 = CLLocationCoordinate2D(latitude: lat2, longitude: long2)
        let fakePlaceMark2 = MKPlacemark(coordinate: fakeCoordinates2)
        let fakeItem2 = MKMapItem(placemark: fakePlaceMark2)
        fakeItem2.name = "Odessa"
        
        let data = [fakeItem1, fakeItem2]
        sut.matchingItems = data
        
    }
    
    override func tearDownWithError() throws {
        sut = nil
        tableView = nil
        delegateMock = nil
        try super.tearDownWithError()
    }
    
    func testNumberOfRows() throws {
        // given
        let numberOfRows = 2
        var fakeNumberOfRows: Int?
        
        // when
        tableView.reloadData()
        fakeNumberOfRows = tableView.numberOfRows(inSection: 0)
        
        // then
        XCTAssertEqual(fakeNumberOfRows, numberOfRows)
    }
    
    func testNumberOfSections() throws {
        // given
        let numberOfSections = 1
        var fakeNumberOfSections: Int?
        
        // when
        tableView.reloadData()
        fakeNumberOfSections = tableView.numberOfSections
        
        // then
        XCTAssertEqual(fakeNumberOfSections, numberOfSections)
        
    }
    
    func testCellForRow() throws {
        // given
        let fakeName = "Kherson"
        var cellName: String?
        
        // when
        tableView.reloadData()
        let cell = tableView.cellForRow(at: IndexPath(row: 0, section: 0))
        cellName = cell?.textLabel?.text
        
        // then
        XCTAssertEqual(fakeName, cellName)
    }
    
    func testDidSelectRow() throws {
        // given
        var wasCellSelected = Bool()
        var name: String?
        var coordinates: String?
        let promise = expectation(description: "DidSelect ended")
        
        // when
        tableView.reloadData()
        sut.tableView(tableView, didSelectRowAt: IndexPath(row: 0, section: 0))
        
        wasCellSelected = delegateMock.didSelectCell
        name = delegateMock.name
        coordinates = delegateMock.coordinates
        promise.fulfill()
        
        wait(for: [promise], timeout: 5)
        
        
        // then
        XCTAssertTrue(wasCellSelected)
        XCTAssertNotNil(name)
        XCTAssertNotNil(coordinates)
    }
}

class RideSearchTableViewDataProviderDelegateMock: RideSearchTableViewDataProviderDelegate {
    var didSelectCell = Bool()
    var name: String?
    var coordinates: String?
    
    func didSelectCell(passedData name: String?, coordinates: String) {
        self.name = name
        self.coordinates = coordinates
        didSelectCell = true
        Log.i("\(self) activated")
    }
    
    
}
