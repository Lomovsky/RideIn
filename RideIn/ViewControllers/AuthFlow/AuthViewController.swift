//
//  AuthViewController.swift
//  RideIn
//
//  Created by Алекс Ломовской on 13.05.2021.
//

import UIKit

final class AuthViewController: UIViewController {

    let button = UIButton.createDefaultButton()
    
    var coordinator: Coordinatable?
    
    var onFinish: CompletionBlock?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.isHidden = true
        
        let notifications = MainNotificationsController()
        notifications.scheduleNotification(ofType: .newRidesAvailable)

        view.addSubview(button)
        view.backgroundColor = .white
        
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
