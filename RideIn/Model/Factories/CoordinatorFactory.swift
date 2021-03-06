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
  func makeApplicationCoordinator() -> Coordinatable
  func makeAuthCoordinator() -> Coordinatable & AuthFlowCoordinatorOutput
  func makeOnboardingFlowCoordinator() -> Coordinatable & OnboardingFlowOutput
  func makeMainFlowCoordinator() -> Coordinatable & MainFlowCoordinatorOutput
}

//MARK:- Coordinator factory
final class CoordinatorFactoryImp: CoordinatorFactory {
  let deepLinkOptions: DeepLinkOptions?
  let navigationController: UINavigationController
  
  init(navigationController: UINavigationController, deepLinkOptions: DeepLinkOptions? = nil) {
    self.deepLinkOptions = deepLinkOptions
    self.navigationController = navigationController
  }
  
  func makeApplicationCoordinator() -> Coordinatable {
    ApplicationCoordinator(navigationController: navigationController)
  }
  
  func makeAuthCoordinator() -> Coordinatable & AuthFlowCoordinatorOutput {
    return AuthCoordinator(navigationController: navigationController)
  }
  
  func makeOnboardingFlowCoordinator() -> Coordinatable & OnboardingFlowOutput {
    return OnboardingFlowCoordinator(navigationController: navigationController)
  }
  
  func makeMainFlowCoordinator() -> (Coordinatable & MainFlowCoordinatorOutput) {
    MainFlowCoordinator(navigationController: navigationController, deepLinkOptions: deepLinkOptions)
  }
}
