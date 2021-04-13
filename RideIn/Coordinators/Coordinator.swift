//
//  Coordinator.swift
//  RideIn
//
//  Created by Алекс Ломовской on 12.04.2021.
//

import UIKit

class BaseCoordinator: Coordinator {
    
    var childCoordinators: [Coordinator] = []
    func start() {}
}

class MainFlowCoordinator: BaseCoordinator {
    
    var router: Routable
    
    init(router: Routable) {
        self.router = router
    }
    
    override func start() {
        startFlow()
    }
    
    func showPassengersVC(withPassengersCount count: String) {
        let vc = PassengersCountViewController()
        vc.coordinator = self
        router.present(vc)
    }
    
    func dismissVC() {
        router.dismissModule()
    }
}

private extension MainFlowCoordinator {
    func startFlow() {
        let vc = RideSearchViewController()
        vc.coordinator = self
        router.setRootModule(vc)
        router.popToRootModule(animated: true)
        
    }
}
