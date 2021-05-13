//
//  MainCoordinatorFactory.swift
//  RideIn
//
//  Created by Алекс Ломовской on 13.05.2021.
//

import UIKit

enum LaunchInstructor {
    case startedFromNotification(Notifications? = nil)
}

protocol CoordinatorFactory {
    var launchInstruction: LaunchInstructor? { get }
    var navigationController: UINavigationController { get }
    func makeCoordinator(withCompletion completion: ((Coordinator) -> Void)?) -> Coordinator?
}

extension CoordinatorFactory {
    func makeCoordinator(withCompletion completion: ((Coordinator) -> Void)? = nil) -> Coordinator? {
        return nil
    }
}

//MARK:- Coordinator factory
class MainCoordinatorFactory: CoordinatorFactory {
    
    var launchInstruction: LaunchInstructor?
    var navigationController: UINavigationController
    
    init(navigationController: UINavigationController, startOptions: LaunchInstructor? = nil) {
        self.launchInstruction = startOptions
        self.navigationController = navigationController
    }
    
    func makeCoordinator(withCompletion completion: ((Coordinator) -> Void)? = nil) -> Coordinator? {
        switch launchInstruction {
        case nil:
            let mainFlowCoordinator = MainFlowCoordinator(navigationController: navigationController)
            guard let completion = completion else { return mainFlowCoordinator }
                completion(mainFlowCoordinator)
                return nil
            
        case .startedFromNotification:
            let mainFlowCoordinator = MainFlowCoordinator(navigationController: navigationController,
                                                          launchInstruction: .startedFromNotification())
            guard let completion = completion else { return mainFlowCoordinator }
            completion(mainFlowCoordinator)
            return nil
        }
    }
}
