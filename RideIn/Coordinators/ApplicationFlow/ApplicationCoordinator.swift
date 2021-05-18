//
//  ApplicationCoordinator.swift
//  RideIn
//
//  Created by Алекс Ломовской on 13.05.2021.
//

import UIKit

private enum LaunchInstructor {
  case auth
  case onboarding
  case main
  
  static func configure(isAuthorized: Bool = AuthorizationStatus.isAuthorized,
                        tutorialWasShown: Bool = OnboardingStatus.onBoardingWasShown) -> LaunchInstructor {
    switch (tutorialWasShown, isAuthorized) {
    case (true, false), (false, false): return .auth
    case (false, true): return .onboarding
    case (true, true): return .main
      
    }
  }
}

//MARK:- Application coordinator
final class ApplicationCoordinator: BaseCoordinator {
  
  private weak var navigationController: UINavigationController?
  
  private var launchInstructor: LaunchInstructor? {
    return LaunchInstructor.configure()
  }
  
  init(navigationController: UINavigationController) {
    super.init(router: Router(rootController: navigationController))
    self.navigationController = navigationController
  }
  
  override func start() {
    switch launchInstructor {
    case .auth:
      runAuthFlow()
      
    case .onboarding:
      runOnboardingFlow()
      
    case .main:
      runMainFlow()
      
    default:
      break
    }
  }
  
  //Can be changed later to it`s not the DRY case
  override func start(with options: DeepLinkOptions? = nil) {
    switch launchInstructor {
    case .auth:
      runAuthFlow()
      
    case .onboarding:
      runOnboardingFlow()
      
    case .main:
      runMainFlow(withOptions: options)
      
    default:
      break
    }
  }
  
  //MARK: authFlow -
  private func runAuthFlow() {
    let coordinatorFactory = CoordinatorFactoryImp(navigationController: navigationController!)
    let coordinator = coordinatorFactory.makeAuthCoordinator() 
    addDependency(coordinator: coordinator)
    
    coordinator.onFinishFlow = { [weak self, weak coordinator = coordinator] in
      guard let coordinator = coordinator else { return }
      self?.removeDependency(coordinator: coordinator)
      AuthorizationStatus.isAuthorized = true
      self?.start()
    }
    
    coordinator.start()
  }
  
  private func runOnboardingFlow() {
    let coordinatorFactory = CoordinatorFactoryImp(navigationController: navigationController!)
    var coordinator = coordinatorFactory.makeOnboardingFlowCoordinator()
    addDependency(coordinator: coordinator)
    
    coordinator.onFinishFlow = { [weak self, weak coordinator = coordinator] in
      guard let coordinator = coordinator else { return }
      self?.removeDependency(coordinator: coordinator)
      OnboardingStatus.onBoardingWasShown = true
      self?.start()
    }
    
    coordinator.start()
  }
  
  //MARK: mainFlow-
  private func runMainFlow(withOptions options: DeepLinkOptions? = nil) {
    let coordinatorFactory: CoordinatorFactory
    
    switch options {
    case nil:
      coordinatorFactory = CoordinatorFactoryImp(navigationController: navigationController!)
      let coordinator = coordinatorFactory.makeMainFlowCoordinator()
      
      addDependency(coordinator: coordinator)
      
      coordinator.onFinishFlow = { [weak self, weak coordinator = coordinator] in
        guard let coordinator = coordinator else { return }
        self?.removeDependency(coordinator: coordinator)
        self?.runAuthFlow()
      }
      
      coordinator.start()
      
    case .notification(_):
      coordinatorFactory = CoordinatorFactoryImp(navigationController: navigationController!, deepLinkOptions: options)
      guard let coordinator = coordinatorFactory.makeMainFlowCoordinator() as? MainFlowCoordinator else { return }
      
      addDependency(coordinator: coordinator)
      
      coordinator.onFinishFlow = { [weak self, weak coordinator = coordinator] in
        guard let coordinator = coordinator else { return }
        self?.removeDependency(coordinator: coordinator)
        self?.runAuthFlow()
      }
      
      coordinator.start(withOptions: options!)
    }
  }
}
