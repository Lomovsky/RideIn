//
//  AuthViewController.swift
//  RideIn
//
//  Created by Алекс Ломовской on 13.05.2021.
//

import UIKit

final class AuthViewController: UIViewController {
  
  var onFinish: CompletionBlock?
  let button = UIButton.createDefaultButton()
  let notifications = MainNotificationsController()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    view.addSubview(button)
    
    notifications.scheduleNotification(ofType: .newRidesAvailable)
    
    setupView()
    setupNavController()
    setupButton()
    
  }
  
  private func setupView() {
    view.backgroundColor = .white
  }
  
  private func setupNavController() {
    navigationController?.navigationBar.isHidden = true
  }
  
  private func setupButton() {
    NSLayoutConstraint.activate([
      button.centerXAnchor.constraint(equalTo: view.centerXAnchor),
      button.centerYAnchor.constraint(equalTo: view.centerYAnchor),
      button.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.06),
      button.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8)
    ])
    button.setTitle("Login", for: .normal)
    button.backgroundColor = .systemBlue
    button.layer.cornerRadius = 15
    button.addTarget(self, action: #selector(login), for: .touchUpInside)
  }
  
  
  @objc private func login() {
    onFinish?()
  }
}
