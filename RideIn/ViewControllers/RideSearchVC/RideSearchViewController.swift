//
//  ViewController.swift
//  RideIn
//
//  Created by Алекс Ломовской on 12.04.2021.
//

import UIKit
import MapKit

protocol RideSearchDelegate: class {
    func changePassengersCount(with operation: Operation)
    func getPassengersCount() -> String
    func continueAfterMapVC(from placeType: PlaceType, withPlaceName name: String)
    func setCoordinates(placemark: MKPlacemark, forPlace placeType: PlaceType)
}

final class RideSearchViewController: UIViewController {
    
    let urlFactory = MainURLFactory()
    let networkManager = MainNetworkManager()
    
    let locationManager = CLLocationManager()
    var matchingItems = [MKMapItem]()
    var region = MKCoordinateRegion()
        
    var timer: Timer?

    var fromCoordinates = String()
    var toCoordinates = String()
    
    var toContentSubviewTopConstraint = NSLayoutConstraint()
    var toTFTopConstraint = NSLayoutConstraint()
    var tableViewSubviewTopConstraint = NSLayoutConstraint()
    
    var placeType: PlaceType?
    var chosenTF = UITextField()
    var fromTextFieldTapped = false
    var toTextFieldTapped = false
    
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
    let fromContentSubview: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let fromBackButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    let fromTextField: UITextField = {
        let tf = UITextField()
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()
    
    let toContentSubview: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let toBackButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
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
    
    let showMapSubview: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let mapImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    let showMapButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    let arrowImageview: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    let searchTableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(RideSearchTableViewCell.self, forCellReuseIdentifier: RideSearchTableViewCell.reuseIdentifier)
        return tableView
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
    
    let mapView: MKMapView = {
        let map = MKMapView()
        map.translatesAutoresizingMaskIntoConstraints = false
        return map
    }()
    
    //MARK: viewDidLoad -
    override func viewDidLoad() {
        super.viewDidLoad()
        searchTableView.dataSource = self
        searchTableView.delegate = self
        locationManager.delegate = self

        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
        
        view.addSubview(fromContentSubview)
        view.addSubview(toContentSubview)
        view.addSubview(toTextField)
        view.addSubview(topLine)
        view.addSubview(dateButton)
        view.addSubview(passengersButton)
        view.addSubview(bottomLine)
        view.addSubview(searchButton)
        view.addSubview(tableViewSubview)
        
        setupNavigationController()
        setupView()
        setupFromContentSubview()
        setupFromBackButton()
        setupFromTF()
        setupToContentSubview()
        setupToBackButton()
        setupToTF()
        setupTopLine()
        setupDateButton()
        setupPassengerButton()
        setupBottomLine()
        setupSearchButton()
        setupTableViewSubview()
        setupMapSubview()
        setupMapImageView()
        setupShowMapButton()
        setupArrowImageView()
        setupSearchTableView()
    }
    
    //MARK: UIMethods -
    private func setupView() {
        view.backgroundColor = .white
    }
    
    private func setupNavigationController() {
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.visibleViewController?.title = "Поиск машины"
        navigationController?.navigationBar.largeTitleTextAttributes = [.foregroundColor: UIColor.darkGray]
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    private func setupFromContentSubview() {
        NSLayoutConstraint.activate([
            fromContentSubview.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 30),
            fromContentSubview.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.9),
            fromContentSubview.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.07),
            fromContentSubview.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
        fromContentSubview.backgroundColor = .systemGray5
        fromContentSubview.layer.cornerRadius = 15
        fromContentSubview.addSubview(fromBackButton)
        fromContentSubview.addSubview(fromTextField)
    }
    
    private func setupFromBackButton() {
        NSLayoutConstraint.activate([
            fromBackButton.centerYAnchor.constraint(equalTo: fromContentSubview.centerYAnchor),
            fromBackButton.leadingAnchor.constraint(equalTo: fromContentSubview.leadingAnchor),
            fromBackButton.heightAnchor.constraint(equalTo: fromContentSubview.heightAnchor),
            fromBackButton.widthAnchor.constraint(equalTo: fromContentSubview.heightAnchor)
        ])
        fromBackButton.backgroundColor = .systemGray5
        fromBackButton.layer.cornerRadius = 15
        fromBackButton.setImage(UIImage(systemName: "chevron.backward"), for: .normal)
        fromBackButton.tintColor = .systemGray
        fromBackButton.isHidden = true
        fromBackButton.addTarget(self, action: #selector(dismissFromTextField), for: .touchUpInside)
    }
    
    private func setupFromTF() {
        NSLayoutConstraint.activate([
            fromTextField.centerYAnchor.constraint(equalTo: fromContentSubview.centerYAnchor),
            fromTextField.trailingAnchor.constraint(equalTo: fromContentSubview.trailingAnchor),
            fromTextField.leadingAnchor.constraint(equalTo: fromBackButton.trailingAnchor),
            fromTextField.heightAnchor.constraint(equalTo: fromContentSubview.heightAnchor),
        ])
        fromTextField.backgroundColor = .systemGray5
        fromTextField.layer.cornerRadius = 15
        fromTextField.attributedPlaceholder = NSAttributedString(string: "Выезжаете из",
                                                                 attributes: [NSAttributedString.Key.foregroundColor: UIColor.systemGray])
        fromTextField.font = .boldSystemFont(ofSize: 16)
        fromTextField.textColor = .black
        fromTextField.textAlignment = .left
        fromTextField.addTarget(self, action: #selector(textFieldDidChange(_:)),
                                for: .editingChanged)
        fromTextField.addTarget(self, action: #selector(textFieldHasBeenActivated), for: .touchDown)
        fromTextField.delegate = self
    }
    
    private func setupToContentSubview() {
        toContentSubviewTopConstraint = NSLayoutConstraint(item: toContentSubview,
                                               attribute: .top,
                                               relatedBy: .equal,
                                               toItem: view.safeAreaLayoutGuide,
                                               attribute: .top,
                                               multiplier: 1,
                                               constant: 45 + (view.frame.height * 0.07))
        
        NSLayoutConstraint.activate([
            toContentSubviewTopConstraint,
            toContentSubview.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.9),
            toContentSubview.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.07),
            toContentSubview.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
        
        toContentSubview.backgroundColor = .systemGray5
        toContentSubview.layer.cornerRadius = 15
        toContentSubview.addSubview(toBackButton)
        toContentSubview.addSubview(toTextField)
    }
    
    private func setupToBackButton() {
        NSLayoutConstraint.activate([
            toBackButton.centerYAnchor.constraint(equalTo: toContentSubview.centerYAnchor),
            toBackButton.leadingAnchor.constraint(equalTo: toContentSubview.leadingAnchor),
            toBackButton.heightAnchor.constraint(equalTo: toContentSubview.heightAnchor),
            toBackButton.widthAnchor.constraint(equalTo: toContentSubview.heightAnchor)
        ])
        toBackButton.backgroundColor = .systemGray5
        toBackButton.layer.cornerRadius = 15
        toBackButton.setImage(UIImage(systemName: "chevron.backward"), for: .normal)
        toBackButton.tintColor = .systemGray
        toBackButton.isHidden = true
        toBackButton.addTarget(self, action: #selector(dismissToTextField), for: .touchUpInside)

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
            toTextField.trailingAnchor.constraint(equalTo: toContentSubview.trailingAnchor),
            toTextField.leadingAnchor.constraint(equalTo: toBackButton.trailingAnchor),
            toTextField.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.07),
        ])
        
        toTextField.backgroundColor = .systemGray5
        toTextField.layer.cornerRadius = 15
        toTextField.attributedPlaceholder = NSAttributedString(string: "Направляетесь в",
                                                               attributes: [NSAttributedString.Key.foregroundColor: UIColor.systemGray])
        toTextField.font = .boldSystemFont(ofSize: 16)
        toTextField.textColor = .black
        toTextField.textAlignment = .left
        toTextField.addTarget(self, action: #selector(textFieldDidChange(_:)),
                              for: .editingChanged)
        toTextField.addTarget(self, action: #selector(textFieldHasBeenActivated), for: .touchDown)
        toTextField.delegate = self
        toTextField.clearButtonMode = .always
    }
    
    private func setupTopLine() {
        NSLayoutConstraint.activate([
            topLine.topAnchor.constraint(equalTo: toContentSubview.bottomAnchor, constant: 20),
            topLine.leadingAnchor.constraint(equalTo: toContentSubview.leadingAnchor),
            topLine.trailingAnchor.constraint(equalTo: toContentSubview.trailingAnchor),
            topLine.heightAnchor.constraint(equalTo: toContentSubview.heightAnchor, multiplier: 0.02)
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
            bottomLine.leadingAnchor.constraint(equalTo: toContentSubview.leadingAnchor),
            bottomLine.trailingAnchor.constraint(equalTo: toContentSubview.trailingAnchor),
            bottomLine.heightAnchor.constraint(equalTo: toContentSubview.heightAnchor, multiplier: 0.02)
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
        tableViewSubview.addSubview(showMapSubview)
        tableViewSubview.addSubview(searchTableView)
    }
    
    private func setupMapSubview() {
        NSLayoutConstraint.activate([
            showMapSubview.topAnchor.constraint(equalTo: tableViewSubview.topAnchor),
            showMapSubview.leadingAnchor.constraint(equalTo: tableViewSubview.leadingAnchor),
            showMapSubview.trailingAnchor.constraint(equalTo: tableViewSubview.trailingAnchor),
            showMapSubview.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.07)
        ])
        showMapSubview.backgroundColor = .white
        showMapSubview.addSubview(mapImageView)
        showMapSubview.addSubview(showMapButton)
        showMapSubview.addSubview(arrowImageview)
    }
    
    private func setupMapImageView() {
        NSLayoutConstraint.activate([
            mapImageView.leadingAnchor.constraint(equalTo: showMapSubview.leadingAnchor, constant: 20),
            mapImageView.centerYAnchor.constraint(equalTo: showMapSubview.centerYAnchor),
            mapImageView.heightAnchor.constraint(equalTo: showMapSubview.heightAnchor, multiplier: 0.5),
            mapImageView.widthAnchor.constraint(equalTo: mapImageView.heightAnchor)
        ])
        mapImageView.backgroundColor = .clear
        mapImageView.tintColor = .darkGray
        mapImageView.image = UIImage(systemName: "mappin.and.ellipse")
    }
    
    private func setupShowMapButton() {
        NSLayoutConstraint.activate([
            showMapButton.centerYAnchor.constraint(equalTo: showMapSubview.centerYAnchor),
            showMapButton.leadingAnchor.constraint(equalTo: mapImageView.trailingAnchor, constant: 10),
            showMapButton.heightAnchor.constraint(equalTo: showMapSubview.heightAnchor, multiplier: 0.5)
        ])
        showMapButton.setTitle("Выбрать на карте", for: .normal)
        showMapButton.setTitleColor(.darkGray, for: .normal)
        showMapButton.titleLabel?.font = .boldSystemFont(ofSize: 20)
        showMapButton.titleLabel?.numberOfLines = 0
        showMapButton.addTarget(self, action: #selector(showMap), for: .touchUpInside)
    }
    
    private func setupArrowImageView() {
        NSLayoutConstraint.activate([
            arrowImageview.trailingAnchor.constraint(equalTo: showMapSubview.trailingAnchor, constant: -20),
            arrowImageview.centerYAnchor.constraint(equalTo: showMapSubview.centerYAnchor)
        ])
        arrowImageview.backgroundColor = .clear
        arrowImageview.tintColor = .darkGray
        arrowImageview.image = UIImage(systemName: "chevron.right")
    }
    
    private func setupSearchTableView() {
        NSLayoutConstraint.activate([
            searchTableView.topAnchor.constraint(equalTo: showMapSubview.bottomAnchor),
            searchTableView.leadingAnchor.constraint(equalTo: tableViewSubview.leadingAnchor),
            searchTableView.trailingAnchor.constraint(equalTo: tableViewSubview.trailingAnchor),
            searchTableView.bottomAnchor.constraint(equalTo: tableViewSubview.bottomAnchor)
        ])
        searchTableView.separatorStyle = .none
        
    }
    
    deinit {
        print("deallocating\(self)")
    }
    
}


