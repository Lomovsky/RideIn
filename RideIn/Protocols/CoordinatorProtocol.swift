//
//  CoordinatorProtocol.swift
//  RideIn
//
//  Created by Алекс Ломовской on 12.04.2021.
//

import UIKit

protocol Coordinator: class {
    var childCoordinators: [Coordinator] { get set }
    func start()
    func addDependency(coordinator: Coordinator)
    func removeDependency(coordinator: Coordinator)
}


extension Coordinator {
    
    func addDependency(coordinator: Coordinator) {
        for element in childCoordinators {
            if element === coordinator { return }
        }
        childCoordinators.append(coordinator)
    }
    
    func removeDependency(coordinator: Coordinator) {
        guard !(childCoordinators.isEmpty) else { return }
        
        for (index, element) in childCoordinators.enumerated() {
            if element === coordinator {
                childCoordinators.remove(at: index)
                break
            }
        }
    }
    
}

