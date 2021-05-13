//
//  AuthFlowCoordinator.swift
//  RideIn
//
//  Created by Алекс Ломовской on 13.05.2021.
//

import UIKit

protocol AuthFlowCoordinatorOutput: AnyObject {
    var onFinishFlow: CompletionBlock? { get set }
}

class AuthCoordinator: BaseCoordinator, AuthFlowCoordinatorOutput {
    
    var onFinishFlow: CompletionBlock?
    
    private weak var navigationController: UINavigationController?

    
    //MARK: init-
    init(navigationController: UINavigationController) {
        super.init(router: Router(rootController: navigationController))
        self.navigationController = navigationController
    }
    
    override func start() {
            showAuth()
    }
    
    private func showAuth() {
        let vc = AuthViewController()
        vc.coordinator = self
        
        vc.onFinish = { [weak self] in
            self?.onFinishFlow?()
        }
        
        router.setRootModule(vc)
    }
    
    deinit {
        Log.i("Deallocating \(self)")
    }
}
