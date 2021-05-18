//
//  NetworkManagerTests.swift
//  RideInTests
//
//  Created by Алекс Ломовской on 26.04.2021.
//

import XCTest
import Alamofire
@testable import RideIn

//MARK:- NetworkManager tests
class unit_NetworkManagerTests: XCTestCase {
  
  var networkManager: NetworkManager!
  
  override func setUpWithError() throws {
    networkManager = MainNetworkManager()
    try super.setUpWithError()
  }
  
  override func tearDownWithError() throws {
    networkManager = nil
    try super.tearDownWithError()
  }
  
  //MARK:- API test
  func testAPI() throws {
    try XCTSkipUnless(ConnectionManager.isConnectedToNetwork())
    
    // given
    let fakeUrlString = "https://public-api.blablacar.com/api/v3/trips?from_coordinate=46.668396,32.646142&to_coordinate=46.966541,32.000077&locale=uk-UA&currency=UAH&key=GU02DX6Tsap6aHH56HaZ0EnR9iGzibBq"
    let url = URL(string: fakeUrlString)!
    let promise = expectation(description: "StatusCode 200")
    var statusCode: Int?
    var responseError: Error?
    
    // when
    let request = AF.request(url)
    request.response { (response) in
      if response.error == nil {
        let JSONResponse = response.response
        statusCode = JSONResponse?.statusCode
      } else {
        responseError = response.error
      }
      promise.fulfill()
    }
    wait(for: [promise], timeout: 5)
    
    // when
    XCTAssertNil(responseError)
    XCTAssertEqual(statusCode, 200)
  }
  
  //MARK:- NetworkManager base request
  func testNetworkManagerBaseRequest() throws {
    try XCTSkipUnless(ConnectionManager.isConnectedToNetwork())
    
    // given
    let fakeUrlString = "https://public-api.blablacar.com/api/v3/trips?from_coordinate=46.668396,32.646142&to_coordinate=46.966541,32.000077&locale=uk-UA&currency=UAH&key=GU02DX6Tsap6aHH56HaZ0EnR9iGzibBq"
    let url = URL(string: fakeUrlString)!
    let promise = expectation(description: "Request succeed")
    var responseError: Error?
    var decodedData: Trips?
    
    // when
    networkManager.downloadData(withURL: url, decodeBy: Trips.self) { (result) in
      switch result {
      case .failure(let error): responseError = error
      case .success(let data): decodedData = data
      }
      promise.fulfill()
    }
    wait(for: [promise], timeout: 5)
    
    // then
    XCTAssertNil(responseError)
    XCTAssertNotNil(decodedData)
  }
  
  //MARK:- BadRequest test
  func testNetworkManagerBadRequest() throws {
    try XCTSkipUnless(ConnectionManager.isConnectedToNetwork())
    
    // given
    let fakeUrlString = "https://public-api.blablacar.com/api/v3/trips?from_coordinate=46.668____396,32.646142&to_coordinate=46.966541,32.000077&locale=uk-UA&currency=UAH&key=GU02DX6Tsap6aHH56HaZ0EnR9iGzibBq"
    let url = URL(string: fakeUrlString)!
    let promise = expectation(description: "Bad request error handled")
    
    // when
    networkManager.downloadData(withURL: url, decodeBy: Trips.self) { (result) in
      switch result {
      case .failure(let error):
        switch error {
        case NetworkManagerErrors.badRequest: promise.fulfill()
        default: XCTFail()
        }
        
      case .success(_): XCTFail()
      }
    }
    
    // then
    wait(for: [promise], timeout: 5)
  }
  
  //MARK:- ConnectionError test
  func testNetworkManagerConnectionError() throws {
    try XCTSkipIf(ConnectionManager.isConnectedToNetwork())
    
    // given
    let fakeUrlString = "https://public-api.blablacar.com/api/v3/trips?from_coordinate=46.668396,32.646142&to_coordinate=46.966541,32.000077&locale=uk-UA&currency=UAH&key=GU02DX6Tsap6aHH56HaZ0EnR9iGzibBq"
    let url = URL(string: fakeUrlString)!
    let promise = expectation(description: "No connection error handled")
    
    // when
    networkManager.downloadData(withURL: url, decodeBy: Trips.self) { (result) in
      switch result {
      case .failure(let error):
        switch error {
        case NetworkManagerErrors.noConnection: promise.fulfill()
        default: XCTFail()
        }
      default: XCTFail()
      }
    }
    
    // then
    wait(for: [promise], timeout: 5)
  }
  
}
