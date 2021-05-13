//
//  AuthViewController.swift
//  RideIn
//
//  Created by Алекс Ломовской on 13.05.2021.
//

import UIKit

final class AuthViewController: UIViewController {

    let button = UIButton.createDefaultButton()
    
    var coordinator: Coordinator?
    
    var onFinish: CompletionBlock?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(button)
        view.backgroundColor = .white
        
        NSLayoutConstraint.activate([
            button.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            button.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        button.setTitle("LOGIN", for: .normal)
        button.backgroundColor = .systemBlue
        button.layer.cornerRadius = 15
        button.addTarget(self, action: #selector(login), for: .touchUpInside)
    }
    

    @objc private func login() {
        onFinish?()
    }
}
