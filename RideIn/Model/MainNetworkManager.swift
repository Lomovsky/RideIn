//
//  MainNetworkManager.swift
//  RideIn
//
//  Created by Алекс Ломовской on 13.04.2021.
//

import UIKit
import Alamofire

final class MainNetworkManager: NetworkManager {
    
    func fetchRides(withURL url: URL) {
        
        let downloadQueue = DispatchQueue(label: "networkManagerQueue", qos: .utility)

        downloadQueue.async {
            let request = AF.request(url)
            request.responseJSON { (response) in
                if let error = response.error {
                    print(error)
                } else {
                    print(response)
//                    guard let JSONData = response.data, let JSONResponse = response.response else { return }
//                    print(JSONResponse)
//
//                    do {
//                        let decodedData = try JSONDecoder().decode(dataModel, from: JSONData)
//                        completion(.success(decodedData))
//                    } catch let error as NSError {
//                        assertionFailure("NETWORK MANAGER FAILURE \(error), \(#line)")
//                    }
                }
            }
        }
    }
    
    
}
