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
    
    func makeAuthCoordinator() -> Coordinator & AuthFlowCoordinatorOutput
    func makeMainFlowCoordinator() -> Coordinator & MainFlowCoordinatorOutput
}


//MARK:- Coordinator factory
class MainCoordinatorFactory: CoordinatorFactory {
    
    let deepLinkOptions: DeepLinkOptions?
    let navigationController: UINavigationController
    
    init(navigationController: UINavigationController, deepLinkOptions: DeepLinkOptions? = nil) {
        self.deepLinkOptions = deepLinkOptions
        self.navigationController = navigationController
    }
    
    func makeMainFlowCoordinator() -> (Coordinator & MainFlowCoordinatorOutput) {
        switch deepLinkOptions {
        case nil:
            return MainFlowCoordinator(navigationController: navigationController)
            
        case .notification(let notification):
            switch notification {
            case .newRidesAvailable:
                return MainFlowCoordinator(navigationController: navigationController,
                                           deepLinkOptions: .notification(notification))
            }
        }
    }
    
    


func makeAuthCoordinator() -> Coordinator & AuthFlowCoordinatorOutput {
    return AuthCoordinator(navigationController: navigationController)
    
}

}
