//
//  MainMapKitPlacesSearchDataProviderTests.swift
//  RideInTests
//
//  Created by Алекс Ломовской on 28.04.2021.
//

import XCTest
import MapKit
@testable import RideIn

class MainMapKitPlacesSearchManagerTests: XCTestCase {
    
    var sut: MainMapKitPlacesSearchManager!
    
    override func setUpWithError() throws {
        sut = MainMapKitPlacesSearchManager()
    }
    
    override func tearDownWithError() throws {
        sut = nil
    }
    
    func testSearchForPlaces() throws {
        // given
        let fakeKeyword = "Kyiv"
        let lat = CLLocationDegrees(46.668396)
        let long = CLLocationDegrees(32.646142)
        let fakeLocation = CLLocation(latitude: lat, longitude: long)
        let fakeSpan = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        let fakeRegion = MKCoordinateRegion(center: fakeLocation.coordinate, span: fakeSpan)
        
        let promise = expectation(description: "Request ended")
        var requestError: Error?
        var items: [MKMapItem]?
        
        // when
        MainMapKitPlacesSearchManager.searchForPlace(with: fakeKeyword, inRegion: fakeRegion) { matchingItems, error in
            requestError = error
            items = matchingItems
            promise.fulfill()
        }
        wait(for: [promise], timeout: 5)
        
        // then
        XCTAssertNil(requestError)
        XCTAssertNotNil(items)
    }
    
}
