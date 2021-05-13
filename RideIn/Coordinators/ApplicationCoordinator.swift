//
//  ApplicationCoordinator.swift
//  RideIn
//
//  Created by Алекс Ломовской on 13.05.2021.
//

import UIKit

private var isAuthorized = false

enum LaunchInstructor {
    case auth
    case main
    
    static func configure(isAuthorized: Bool = isAuthorized) -> LaunchInstructor {
      switch (isAuthorized) {
      case true: return .main
      case false: return .auth
        
      }
    }
}

enum DeepLinkOptions {
    case notification(Notifications)
}

class ApplicationCoordinator: BaseCoordinator {
    
    private weak var navigationController: UINavigationController?
    
    private var deepLinkOptions: DeepLinkOptions?
    
    private var launchInstructor: LaunchInstructor? {
        return LaunchInstructor.configure()
    }
    
    init(navigationController: UINavigationController, deepLinkOptions: DeepLinkOptions? = nil) {
        super.init(router: Router(rootController: navigationController))
        self.navigationController = navigationController
        self.deepLinkOptions = deepLinkOptions
    }
    
    override func start() {
        switch launchInstructor {
        case .auth:
            runAuthFlow()
            
        case .main:
            runMainFlow()
            
        default:
            break
        }
    }
    
    private func runAuthFlow() {
        let coordinatorFactory = MainCoordinatorFactory(navigationController: navigationController!)
        let coordinator = coordinatorFactory.makeAuthCoordinator() 
        addDependency(coordinator: coordinator)
        
        coordinator.onFinishFlow = { [weak self] in
            self?.removeDependency(coordinator: coordinator)
            isAuthorized = true
            self?.start()
        }
        
        coordinator.start()
    }
    
    private func runMainFlow() {
        let coordinatorFactory: CoordinatorFactory
        
        switch deepLinkOptions {
        case nil:
            coordinatorFactory = MainCoordinatorFactory(navigationController: navigationController!)
        case .notification(let notification):
            coordinatorFactory = MainCoordinatorFactory(navigationController: navigationController!,
                                                        deepLinkOptions: .notification(notification))
        }
        
        let coordinator = coordinatorFactory.makeMainFlowCoordinator()
        
        addDependency(coordinator: coordinator)
        
        coordinator.onFinishFlow = { [weak self] in
            self?.removeDependency(coordinator: coordinator)
            self?.runAuthFlow()
        }
        
        coordinator.start()
    }
}
