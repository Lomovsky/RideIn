//
//  MainCoordinatorFactory.swift
//  RideIn
//
//  Created by Алекс Ломовской on 13.05.2021.
//

import UIKit


protocol CoordinatorFactory {
    
    var deepLinkOptions: DeepLinkOptions? { get }
    var navigationController: UINavigationController { get }
    
    func makeApplicationCoordinator() -> Coordinator
    
    func makeAuthCoordinator() -> Coordinator & AuthFlowCoordinatorOutput
    func makeMainFlowCoordinator() -> Coordinator & MainFlowCoordinatorOutput
    
}


//MARK:- Coordinator factory
class CoordinatorFactoryImp: CoordinatorFactory {
    
    let deepLinkOptions: DeepLinkOptions?
    let navigationController: UINavigationController
    
    init(navigationController: UINavigationController, deepLinkOptions: DeepLinkOptions? = nil) {
        self.deepLinkOptions = deepLinkOptions
        self.navigationController = navigationController
    }
    
    func makeApplicationCoordinator() -> Coordinator {
        switch deepLinkOptions {
        case nil:
            return ApplicationCoordinator(navigationController: navigationController)
            
        case .notification(_):
            return ApplicationCoordinator(navigationController: navigationController, deepLinkOptions: deepLinkOptions)
        }
    }
    
    func makeMainFlowCoordinator() -> (Coordinator & MainFlowCoordinatorOutput) {
        switch deepLinkOptions {
        case nil:
            return MainFlowCoordinator(navigationController: navigationController)
            
        case .notification(_):
                return MainFlowCoordinator(navigationController: navigationController, deepLinkOptions: deepLinkOptions)
            
        }
    }
    
    func makeAuthCoordinator() -> Coordinator & AuthFlowCoordinatorOutput {
        return AuthCoordinator(navigationController: navigationController)
    }
    
}
