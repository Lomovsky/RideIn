//
//  WelcomeOnboardingViewcontroller.swift
//  RideIn
//
//  Created by Алекс Ломовской on 18.05.2021.
//

import UIKit

final class GreetingsOnboardingViewController: UIViewController {
  
  var onNext: CompletionBlock?
  private let greetingsLabel = UILabel.createDefaultLabel()
  private let welcomeLabel = UILabel.createDefaultLabel()
  private let detailsLabel = UILabel.createDefaultLabel()
  private let nextButton = UIButton.createDefaultButton()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    view.addSubview(greetingsLabel)
    view.addSubview(welcomeLabel)
    view.addSubview(nextButton)
    
    setupView()
    setupNavigationController()
    setupGreetingsLabel()
    setupWelcomeLabel()
    setupNextButton()
    
  }
  
  //MARK:- UIMethods
  private func setupView() {
    view.backgroundColor = .white
  }
  
  private func setupNavigationController() {
    navigationController?.navigationBar.isHidden = true
  }
  
  private func setupGreetingsLabel() {
    NSLayoutConstraint.activate([
      greetingsLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
      greetingsLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),
      greetingsLabel.bottomAnchor.constraint(equalTo: view.centerYAnchor, constant: -(view.frame.height * 0.2)),
      greetingsLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
    ])
    greetingsLabel.text = NSLocalizedString(.Localization.Onboarding.greetings, comment: "")
    greetingsLabel.textColor = .darkGray
    greetingsLabel.textAlignment = .center
    greetingsLabel.font = .boldSystemFont(ofSize: 45)
  }
  
  private func setupWelcomeLabel() {
    NSLayoutConstraint.activate([
      welcomeLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
      welcomeLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -(view.frame.height * 0.1)),
    ])
    welcomeLabel.text = "" + NSLocalizedString(.Localization.Onboarding.welcome, comment: "")
    welcomeLabel.textColor = .darkGray
    welcomeLabel.numberOfLines = 0
    welcomeLabel.sizeToFit()
    welcomeLabel.textAlignment = .center
    welcomeLabel.font = .boldSystemFont(ofSize: 20)
  }
  
  private func setupNextButton() {
    NSLayoutConstraint.activate([
      nextButton.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.07),
      nextButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8),
      nextButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
      nextButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -5)
    ])
    nextButton.backgroundColor = .systemBlue
    nextButton.layer.cornerRadius = 12
    nextButton.setTitleColor(.white, for: .normal)
    nextButton.setTitle(NSLocalizedString(.Localization.Onboarding.next, comment: ""), for: .normal)
    nextButton.addTarget(self, action: #selector(nextButtonTapped), for: .touchUpInside)
  }
  
}

//MARK:- Helming methods
private extension GreetingsOnboardingViewController {
  @objc func nextButtonTapped() {
    onNext?()
  }
}


