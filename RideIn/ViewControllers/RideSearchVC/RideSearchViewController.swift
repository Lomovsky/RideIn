//
//  ViewController.swift
//  RideIn
//
//  Created by Алекс Ломовской on 12.04.2021.
//

import UIKit

enum Declensions {
    case one
    case two
    case more
}

enum Operation {
    case increase
    case decrease
}

protocol RideSearchDelegate: class {
    func changePassengersCount(with operation: Operation)
    func getPassengersCount() -> String
}

final class RideSearchViewController: UIViewController {
    
    let urlFactory = MainURLFactory()
    let networkManager = MainNetworkManager()
    
    var toTFTopConstraint = NSLayoutConstraint()
    var tableViewSubviewTopConstraint = NSLayoutConstraint()
    
    var fromTextFieldTapped = false
    var toTextFieldTapped = false
    var date = Date()
    var passengersCount = 1
    var passengerDeclension: Declensions {
        get {
            if passengersCount == 1 {
                return .one
            } else if passengersCount < 4, passengersCount != 1 {
                return .two
            } else {
                return .more
            }
        }
    }
    
    //MARK: UIElements -
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
    
    let tableViewSubview: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
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
    
    //MARK: viewDidLoad -
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(fromTextField)
        view.addSubview(toTextField)
        view.addSubview(topLine)
        view.addSubview(dateButton)
        view.addSubview(passengersButton)
        view.addSubview(bottomLine)
        view.addSubview(searchButton)
        view.addSubview(tableViewSubview)
        
        
        setupView()
        setupNavigationController()
        setupFromTF()
        setupToTF()
        setupTopLine()
        setupDateButton()
        setupPassengerButton()
        setupBottomLine()
        setupSearchButton()
        setupTableViewSubview()
    }
    
    //MARK: UIMethods -
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
        fromTextField.addTarget(self, action: #selector(textFieldHasBeenActivated), for: .touchDown)
        fromTextField.delegate = self
    }
    
    private func setupToTF() {
        toTFTopConstraint = NSLayoutConstraint(item: toTextField,
                                               attribute: .top,
                                               relatedBy: .equal,
                                               toItem: view.safeAreaLayoutGuide,
                                               attribute: .top,
                                               multiplier: 1,
                                               constant: 45 + (view.frame.height * 0.07))
        NSLayoutConstraint.activate([
            toTFTopConstraint,
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
        toTextField.addTarget(self, action: #selector(textFieldHasBeenActivated), for: .touchDown)
        toTextField.delegate = self
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
        setCount()
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
    
    private func setupTableViewSubview() {
        NSLayoutConstraint.activate([
            tableViewSubview.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableViewSubview.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableViewSubview.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        tableViewSubview.isHidden = true
        tableViewSubview.backgroundColor = .white
        tableViewSubview.alpha = 0.0
    }
    
    deinit {
        print("deallocating\(self)")
    }
    
}


