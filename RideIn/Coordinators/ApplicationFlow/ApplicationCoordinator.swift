//
//  ApplicationCoordinator.swift
//  RideIn
//
//  Created by Алекс Ломовской on 13.05.2021.
//

import UIKit

private enum LaunchInstructor {
    case auth
    case main
    
    static func configure(isAuthorized: Bool = AuthorizationStatus.isAuthorized) -> LaunchInstructor {
        switch (isAuthorized) {
        case true: return .main
        case false: return .auth
            
        }
    }
}

//MARK:- Application coordinator
final class ApplicationCoordinator: BaseCoordinator {
    
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
            runMainFlow(withOptions: deepLinkOptions)
            
        default:
            break
        }
    }
    
    //MARK: authFlow -
    private func runAuthFlow() {
        let coordinatorFactory = CoordinatorFactoryImp(navigationController: navigationController!)
        let coordinator = coordinatorFactory.makeAuthCoordinator() 
        addDependency(coordinator: coordinator)
        
        coordinator.onFinishFlow = { [weak self, unowned coordinator = coordinator] in
            self?.removeDependency(coordinator: coordinator)
            AuthorizationStatus.isAuthorized = true
            self?.start()
        }
        
        coordinator.start()
    }
    
    //MARK: mainFlow-
    private func runMainFlow(withOptions options: DeepLinkOptions?) {
        let coordinatorFactory: CoordinatorFactory
        
        switch options {
        case nil:
            coordinatorFactory = CoordinatorFactoryImp(navigationController: navigationController!)
            let coordinator = coordinatorFactory.makeMainFlowCoordinator()
            
            addDependency(coordinator: coordinator)
            
            coordinator.onFinishFlow = { [weak self, unowned coordinator = coordinator] in
                self?.removeDependency(coordinator: coordinator)
                self?.runAuthFlow()
            }
            
            coordinator.start()
            
        case .notification(_):
            coordinatorFactory = CoordinatorFactoryImp(navigationController: navigationController!, deepLinkOptions: options)
            guard let coordinator = coordinatorFactory.makeMainFlowCoordinator() as? MainFlowCoordinator else { return }
            
            addDependency(coordinator: coordinator)
            
            coordinator.onFinishFlow = { [weak self, unowned coordinator = coordinator] in
                self?.removeDependency(coordinator: coordinator)
                self?.runAuthFlow()
            }
            
            coordinator.start(withOptions: options!)
        }
    }
}
