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
    
    override func setUpWithError() throws {
        try super.setUpWithError()
    }

    override func tearDownWithError() throws {
        try super.tearDownWithError()
    }

    func testFetchRequest() throws {
        try XCTSkipUnless(
            ConnectionManager.isConnectedToNetwork(),
          "Network connectivity needed for this test.")
        
        //given
        let urlString = "https://public-api.blablacar.com/api/v3/trips?from_coordinate=46.668396,32.646142&to_coordinate=46.966541,32.000077&locale=uk-UA&currency=UAH&key=GU02DX6Tsap6aHH56HaZ0EnR9iGzibBq"
        let url = URL(string: urlString)!
        let promise = expectation(description: "Completion handler invoked")
        var statusCode: Int?
        var responseError: Error?
        
        //when
        let request = AF.request(url)
        request.responseJSON { (response) in
            if let error = response.error {
                responseError = error
            } else {
                guard let JSONResponse = response.response else { return }
                print(JSONResponse)
                statusCode = JSONResponse.statusCode
                promise.fulfill()
            }
        }
        wait(for: [promise], timeout: 5)
        
        //then
        XCTAssertNil(responseError)
        XCTAssertEqual(statusCode, 200)
    }

}
