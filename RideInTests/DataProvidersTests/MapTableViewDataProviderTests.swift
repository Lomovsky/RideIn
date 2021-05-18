//
//  MapTableViewDataProviderTests.swift
//  RideInTests
//
//  Created by Алекс Ломовской on 29.04.2021.
//

import XCTest
import MapKit
@testable import RideIn

class MapTableViewDataProviderTests: XCTestCase {
  
  var sut: MapTableViewDataProvider!
  var delegateMock: MapTableViewDataProviderDelegateMock!
  var tableView: UITableView!
  
  override func setUpWithError() throws {
    try super.setUpWithError()
    sut = MapTableViewDataProvider()
    tableView = UITableView()
    delegateMock = MapTableViewDataProviderDelegateMock()
    sut.delegate = delegateMock
    
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
    tableView.register(MapTableViewCell.self, forCellReuseIdentifier: MapTableViewCell.reuseIdentifier)
    tableView.delegate = sut
    tableView.dataSource = sut
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
    var didSelectCell = Bool()
    var placemark: MKPlacemark?
    
    // when
    tableView.reloadData()
    sut.tableView(tableView, didSelectRowAt: IndexPath(row: 0, section: 0))
    didSelectCell = delegateMock.didSelectCell
    placemark = delegateMock.placemark
    
    // then
    XCTAssertTrue(didSelectCell)
    XCTAssertNotNil(placemark)
  }
  
}

class MapTableViewDataProviderDelegateMock: MapTableViewDataProviderDelegate {
  var didSelectCell = Bool()
  var placemark: MKPlacemark?
  
  func didSelectCell(passedData placeMark: MKPlacemark) {
    placemark = placeMark
    didSelectCell = true
  }
  
  
}
