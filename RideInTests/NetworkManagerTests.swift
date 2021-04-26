//
//  NetworkManagerTests.swift
//  RideInTests
//
//  Created by Алекс Ломовской on 26.04.2021.
//

import XCTest
import Alamofire
@testable import RideIn

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
    
    func testAPI() throws {
        try XCTSkipUnless(ConnectionManager.isConnectedToNetwork())
        
        // given
        let urlString = "https://public-api.blablacar.com/api/v3/trips?from_coordinate=46.668396,32.646142&to_coordinate=46.966541,32.000077&locale=uk-UA&currency=UAH&key=GU02DX6Tsap6aHH56HaZ0EnR9iGzibBq"
        let url = URL(string: urlString)!
        let promise = expectation(description: "StatusCode 200")
        
        // when
        let request = AF.request(url)
        request.response { (response) in
            if response.error == nil {
                let JSONResponse = response.response
                if JSONResponse?.statusCode == 200 {
                    promise.fulfill()
                }
            } else {
                XCTFail("Request error")
            }
        }
        // then
        wait(for: [promise], timeout: 5)
    }
    
    
    func testNetworkManager() throws {
        // given
        let urlString = "https://public-api.blablacar.com/api/v3/trips?from_coordinate=46.668396,32.646142&to_coordinate=46.966541,32.000077&locale=uk-UA&currency=UAH&key=GU02DX6Tsap6aHH56HaZ0EnR9iGzibBq"
        let url = URL(string: urlString)!
        let promise = expectation(description: "Data recieved")
        
        // when
        networkManager.downloadData(withURL: url, decodeBy: Trips.self) { (result) in
            switch result {
            case .failure(_): XCTFail("An error occured")
            case .success(_): promise.fulfill()
            }
        }
        
        // then
        wait(for: [promise], timeout: 5)
    }
    
    
}
