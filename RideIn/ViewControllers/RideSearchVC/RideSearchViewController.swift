//
//  ViewController.swift
//  RideIn
//
//  Created by Алекс Ломовской on 12.04.2021.
//

import UIKit



final class RideSearchViewController: UIViewController {

    weak var coordinator: MainFlowCoordinator?
    var viewModel: RideSearchViewViewModelType = RideSearchViewViewModel()
    let searchController = UISearchController(searchResultsController: nil)
    
    let fromTextField: UITextField = {
        let tf = UITextField()
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()
    
    let toTextField: UITextField = {
        let tf = UITextField()
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()
    
    let topLine: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let dateButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    let passengersButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    let bottomLine: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let searchButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        RideSearchViewViewModel.rideSearchDelegate = self
        
        view.addSubview(fromTextField)
        view.addSubview(toTextField)
        view.addSubview(topLine)
        view.addSubview(dateButton)
        view.addSubview(passengersButton)
        view.addSubview(bottomLine)
        view.addSubview(searchButton)
        
        setupView()
        setupNavigationController()
        setupFromTF()
        setupToTF()
        setupTopLine()
        setupDateButton()
        setupPassengerButton()
        setupBottomLine()
        setupSearchButton()
    }


    private func setupView() {
        view.backgroundColor = .white
    }
    
    private func setupNavigationController() {
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.visibleViewController?.title = "Поиск машины"
        navigationController?.navigationBar.largeTitleTextAttributes = [.foregroundColor: UIColor.darkGray]
    }
    
    private func setupFromTF() {
        NSLayoutConstraint.activate([
            fromTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 30),
            fromTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            fromTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            fromTextField.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.07)
        ])
        fromTextField.backgroundColor = .systemGray5
        fromTextField.layer.cornerRadius = 15
        fromTextField.attributedPlaceholder = NSAttributedString(string: "Выезжаете из",
                                                                 attributes: [NSAttributedString.Key.foregroundColor: UIColor.systemGray])
        fromTextField.font = .boldSystemFont(ofSize: 16)
        fromTextField.textColor = .black
        fromTextField.textAlignment = .center
        fromTextField.addTarget(self, action: #selector(textFieldDidChange(_:)),
                                for: .editingChanged)
    }
    
    private func setupToTF() {
        NSLayoutConstraint.activate([
            toTextField.topAnchor.constraint(equalTo: fromTextField.bottomAnchor, constant: 15),
            toTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            toTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            toTextField.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.07)
        ])
        toTextField.backgroundColor = .systemGray5
        toTextField.layer.cornerRadius = 15
        toTextField.attributedPlaceholder = NSAttributedString(string: "Направляетесь в",
                                                                 attributes: [NSAttributedString.Key.foregroundColor: UIColor.systemGray])
        toTextField.font = .boldSystemFont(ofSize: 16)
        toTextField.textColor = .black
        toTextField.textAlignment = .center
        toTextField.addTarget(self, action: #selector(textFieldDidChange(_:)),
                              for: .editingChanged)
    }
    
    private func setupTopLine() {
        NSLayoutConstraint.activate([
            topLine.topAnchor.constraint(equalTo: toTextField.bottomAnchor, constant: 20),
            topLine.leadingAnchor.constraint(equalTo: toTextField.leadingAnchor),
            topLine.trailingAnchor.constraint(equalTo: toTextField.trailingAnchor),
            topLine.heightAnchor.constraint(equalTo: toTextField.heightAnchor, multiplier: 0.02)
        ])
        topLine.backgroundColor = .systemGray5
    }
    
    private func setupDateButton() {
        NSLayoutConstraint.activate([
            dateButton.topAnchor.constraint(equalTo: topLine.bottomAnchor, constant: 20),
            dateButton.leadingAnchor.constraint(equalTo: topLine.leadingAnchor),
        ])
        dateButton.setTitle("Сегодня", for: .normal)
        dateButton.setTitleColor(.lightBlue, for: .normal)
        dateButton.titleLabel?.font = .boldSystemFont(ofSize: 16)
    }
    
    private func setupPassengerButton() {
        NSLayoutConstraint.activate([
            passengersButton.topAnchor.constraint(equalTo: topLine.bottomAnchor, constant: 20),
            passengersButton.leadingAnchor.constraint(equalTo: view.centerXAnchor, constant: 15)
        ])
        passengersButton.setTitle(RideSearchViewViewModel.getPassengers() + " пассажиров", for: .normal)
        passengersButton.setTitleColor(.lightBlue, for: .normal)
        passengersButton.titleLabel?.font = .boldSystemFont(ofSize: 16)
        passengersButton.addTarget(self, action: #selector(setPassengersCount), for: .touchUpInside)
    }
    
    private func setupBottomLine() {
        NSLayoutConstraint.activate([
            bottomLine.topAnchor.constraint(equalTo: passengersButton.bottomAnchor, constant: 20),
            bottomLine.leadingAnchor.constraint(equalTo: toTextField.leadingAnchor),
            bottomLine.trailingAnchor.constraint(equalTo: toTextField.trailingAnchor),
            bottomLine.heightAnchor.constraint(equalTo: toTextField.heightAnchor, multiplier: 0.02)
        ])
        bottomLine.backgroundColor = .systemGray5
    }
    
    private func setupSearchButton() {
        NSLayoutConstraint.activate([
            searchButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            searchButton.topAnchor.constraint(equalTo: bottomLine.bottomAnchor, constant: 20)
        ])
        searchButton.setTitle("SEARCH BETA", for: .normal)
        searchButton.setTitleColor(.systemRed, for: .normal)
        searchButton.addTarget(self, action: #selector(search), for: .touchUpInside)
    }
    
    deinit {
        print("deallocating\(self)")
    }

}


