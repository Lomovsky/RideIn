//
//  BaseCoordinator.swift
//  RideIn
//
//  Created by Алекс Ломовской on 05.05.2021.
//

import UIKit
import MapKit

//MARK:- CoordinatorProtocol
protocol Coordinatable: AnyObject {
    var childCoordinators: [Coordinatable] { get set }
    var router: Router { get }
    func start()
    func addDependency(coordinator: Coordinatable)
    func removeDependency(coordinator: Coordinatable)
}

extension Coordinatable {
    
    func addDependency(coordinator: Coordinatable) {
        for element in childCoordinators {
            if element === coordinator { return }
        }
        childCoordinators.append(coordinator)
    }
    
    func removeDependency(coordinator: Coordinatable) {
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
class BaseCoordinator: Coordinatable {
    
    var childCoordinators = [Coordinatable]()
    
    var router: Router
    
    init(router: Router) {
        self.router = router
    }
    
    func start() {}
}
