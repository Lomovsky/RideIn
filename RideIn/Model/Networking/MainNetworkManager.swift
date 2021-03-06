//
//  MainNetworkManager.swift
//  RideIn
//
//  Created by Алекс Ломовской on 13.04.2021.
//

import Alamofire

/// Request errors
enum NetworkManagerErrors: Error {
  case badRequest
  case noConnection
  case unableToMakeURL
  case noTrips
}

protocol NetworkManager {
  func downloadData<DataModel: Codable>(
    withURL url: URL,
    decodeBy dataModel: DataModel.Type,
    completionHandler: @escaping (Result<DataModel, Error>
    ) -> Void)
}

//MARK:- MainNetworkManager
struct MainNetworkManager: NetworkManager {
  /// This is main method for downloading data
  /// - Parameters:
  ///   - url: Url to download data
  ///   - dataModel: Any data model by which the response should be decoded
  ///   - completionHandler: completion handler with Result type to work with downloaded data and manage possible errors
  func downloadData<DataModel>(
    withURL url: URL,
    decodeBy dataModel: DataModel.Type,
    completionHandler: @escaping (Result<DataModel, Error>
    ) -> Void) where DataModel: Decodable, DataModel: Encodable {
    
    let downloadQueue = DispatchQueue(label: "networkManagerQueue", qos: .utility)
    guard ConnectionManager.isConnectedToNetwork() else {
      let error = NetworkManagerErrors.noConnection
      completionHandler(.failure(error))
      return
    }
    downloadQueue.async {
      let request = AF.request(url)
      request.responseJSON { (response) in
        if let error = response.error {
          completionHandler(.failure(error))
        } else {
          guard let JSONData = response.data, let JSONResponse = response.response else { return }
          Log.v(JSONResponse)
          guard JSONResponse.statusCode == 200 else {
            let error = NetworkManagerErrors.badRequest
            completionHandler(.failure(error))
            return
          }
          
          do {
            let decodedData = try JSONDecoder().decode(dataModel.self, from: JSONData)
            completionHandler(.success(decodedData))
            
          } catch let error as NSError {
            assertionFailure("NETWORK MANAGER FAILURE \(error), \(#line)")
          }
        }
      }
    }
  }
}

