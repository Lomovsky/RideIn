//
//  OnboardingFlowCoordinator.swift
//  RideIn
//
//  Created by Алекс Ломовской on 18.05.2021.
//

import UIKit

protocol OnboardingFlowOutput {
    var onFinishFlow: CompletionBlock? { get set }
}

final class OnboardingFlowCoordinator: BaseCoordinator, OnboardingFlowOutput {
    
    var onFinishFlow: CompletionBlock?
    
    private weak var navigationController: UINavigationController?
    
    init(navigationController: UINavigationController) {
        super.init(router: Router(rootController: navigationController))
        self.navigationController = navigationController
    }
    
    override func start() {
        showGreetingsView()
    }

    private func showGreetingsView() {
        let vc = GreetingsOnboardingViewController()
        vc.coordinator = self
        
        vc.onNext = { [weak self] in
            self?.showWhatThisAppCanDoView()
        }
        
        router.setRootModule(vc, animated: true)
    }
    
    private func showWhatThisAppCanDoView() {
        let vc = WhatThisAppDoViewController()
        vc.coordinator = self
        
        vc.onContinue = { [weak self] in
            self?.onFinishFlow?()
        }
        
        router.push(vc)
    }
    

}
