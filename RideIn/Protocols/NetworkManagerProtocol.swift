//
//  NetworkManagerProtocol.swift
//  RideIn
//
//  Created by Алекс Ломовской on 13.04.2021.
//

import Foundation

protocol NetworkManager {
    func fetchRides(withURL url: URL, completionHandler: @escaping (Result<[Trip], Error>) -> Void)
}
