//
//  MainNetworkManager.swift
//  RideIn
//
//  Created by Алекс Ломовской on 13.04.2021.
//

import UIKit
import Alamofire

final class MainNetworkManager: NetworkManager {
    
    func fetchRides(withURL url: URL, completionHandler: @escaping (Result<[Trip], Error>) -> Void) {
        
        let downloadQueue = DispatchQueue(label: "networkManagerQueue", qos: .utility)
        
        downloadQueue.async {
            let request = AF.request(url)
            request.responseJSON { (response) in
                if let error = response.error {
                    completionHandler(.failure(error))
                } else {
                    guard let JSONData = response.data, let JSONResponse = response.response else { return }
                    print(JSONResponse)
                    guard JSONResponse.statusCode != 400 else { let error = RequestErrors.badRequest; completionHandler(.failure(error)); return}
                    
                    do {
                        let decodedData = try JSONDecoder().decode(Trips.self, from: JSONData)
                        let trips = decodedData.trips
                        completionHandler(.success(trips))
                        
                    } catch let error as NSError {
                        assertionFailure("NETWORK MANAGER FAILURE \(error), \(#line)")
                    }
                }
            }
        }
    }
    
    
    deinit {
        print("deallocating\(self)")
    }
    
}

