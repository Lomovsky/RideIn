//
//  BaseCoordinator.swift
//  RideIn
//
//  Created by Алекс Ломовской on 05.05.2021.
//

import UIKit
import MapKit

//MARK:- CoordinatorProtocol
protocol Coordinator: AnyObject {
    var childCoordinators: [Coordinator] { get set }
    var router: Router { get }
    func start()
    func addDependency(coordinator: Coordinator)
    func removeDependency(coordinator: Coordinator)
    func getNavController() -> UINavigationController
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

//MARK: - BaseCoordinator
class BaseCoordinator: Coordinator {
    var childCoordinators = [Coordinator]()
    
    var router: Router
    
    init(router: Router) {
        self.router = router
    }
    
    func start() {}
    
    func getNavController() -> UINavigationController {
        return UINavigationController()
        
    }
}
