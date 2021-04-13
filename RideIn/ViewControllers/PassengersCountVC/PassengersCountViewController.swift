//
//  ViewController.swift
//  RideIn
//
//  Created by Алекс Ломовской on 12.04.2021.
//

import UIKit

final class PassengersCountViewController: UIViewController {

    weak var coordinator: MainFlowCoordinator?
    var viewModel: PassengersCountViewViewModelType = PassengersCountViewViewModel()
    
//    let cancelButton: UIButton = {
//        let button = UIButton()
//        button.translatesAutoresizingMaskIntoConstraints = false
//        return button
//    }()
    
    let controllerTitle: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let minusButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    let plusButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    let countLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(controllerTitle)
        view.addSubview(minusButton)
        view.addSubview(countLabel)
        view.addSubview(plusButton)
                
        setupView()
        setupTitle()
        setupMinusButton()
        setupCountLabel()
        setupPlusButton()
    }
    
    private func setupView() {
        view.backgroundColor = .white
    }
    
    private func setupTitle() {
        NSLayoutConstraint.activate([
            controllerTitle.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            controllerTitle.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            controllerTitle.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            controllerTitle.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
        controllerTitle.textAlignment = .center
        controllerTitle.textColor = .darkGray
        controllerTitle.text = "Подтвердите количество мест для бронирования"
        controllerTitle.font = .boldSystemFont(ofSize: 30)
        controllerTitle.numberOfLines = 0
    }
    
    private func setupMinusButton() {
        NSLayoutConstraint.activate([
            minusButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            minusButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            minusButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.1),
            minusButton.heightAnchor.constraint(equalTo: minusButton.widthAnchor)
        ])
        minusButton.setImage(UIImage(systemName: "minus.circle"), for: .normal)
        minusButton.imageView?.contentMode = .scaleAspectFit
        minusButton.contentVerticalAlignment = .fill
        minusButton.contentHorizontalAlignment = .fill
        minusButton.tintColor = .lightBlue
        minusButton.addTarget(self, action: #selector(removePassenger), for: .touchUpInside)
    }
    
    private func setupCountLabel() {
        NSLayoutConstraint.activate([
            countLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            countLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
        setCount()
        countLabel.textColor = .darkGray
        countLabel.font = .boldSystemFont(ofSize: 60)
    }
    
    private func setupPlusButton() {
        NSLayoutConstraint.activate([
            plusButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            plusButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            plusButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.1),
            plusButton.heightAnchor.constraint(equalTo: plusButton.widthAnchor)
        ])
        plusButton.setImage(UIImage(systemName: "plus.circle"), for: .normal)
        plusButton.imageView?.contentMode = .scaleAspectFit
        plusButton.contentVerticalAlignment = .fill
        plusButton.contentHorizontalAlignment = .fill
        plusButton.tintColor = .lightBlue
        plusButton.addTarget(self, action: #selector(addPassenger), for: .touchUpInside)
    }
    
    deinit {
        print("dealloccation \(self)")
    }

}


extension PassengersCountViewController {
    
    @objc final func cancel() {
        coordinator?.dismissVC()
    }
    
    @objc final func addPassenger() {
        viewModel.addPassenger()
        setCount()
    }
    
    @objc final func removePassenger() {
        viewModel.removePassenger()
        setCount()
    }
    
    func setCount() {
        countLabel.text = viewModel.getPassengersCount()
    }
  
}
