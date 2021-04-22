//
//  MapViewController.swift
//  RideIn
//
//  Created by Алекс Ломовской on 14.04.2021.
//

import UIKit
import MapKit


final class MapViewController: UIViewController {

    let locationManager = CLLocationManager()
    var matchingItems = [MKMapItem]()
    var selectedPin: MKPlacemark? = nil
    
    var placeType: PlaceType?
    var timer: Timer?
    
    var ignoreLocation = false
    var gestureRecognizerEnabled = true
    var textFieldActivated = false
    
    weak var rideSearchDelegate: RideSearchDelegate?
    
    //MARK: UIElements-
    let navigationSubview: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let contentSubview: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let backButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    let searchTF: UITextField = {
        let tf = UITextField()
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()
    
    let mapView: MKMapView = {
        let map = MKMapView()
        map.translatesAutoresizingMaskIntoConstraints = false
        return map
    }()
    
    let placesTableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(MapTableViewCell.self, forCellReuseIdentifier: MapTableViewCell.reuseIdentifier)
        return tableView
    }()
    
    let proceedButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
 
    
    //MARK: viewDidLoad -
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
        mapView.delegate = self
        placesTableView.dataSource = self
        placesTableView.delegate = self
        
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
        
        view.addSubview(navigationSubview)
        view.addSubview(contentSubview)
        view.addSubview(mapView)
        view.addSubview(proceedButton)
        view.addSubview(placesTableView)
        
        setupLongTapRecognizer()
        
        setupView()
        setupNavigationView()
        setupContentSubview()
        setupMapView()
        setupBackButton()
        setupSearchTF()
        setupTableView()
        setupProceedButton()
    }
    
    
    //MARK: UIMethods -
    private func setupView() {
        view.backgroundColor = .white
    }
    
    private func setupNavigationView() {
        NSLayoutConstraint.activate([
            navigationSubview.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            navigationSubview.topAnchor.constraint(equalTo: view.topAnchor),
            navigationSubview.widthAnchor.constraint(equalTo: view.widthAnchor),
            navigationSubview.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: (view.frame.height * 0.08))
        ])
        navigationSubview.backgroundColor = .white
    }
    
    private func setupContentSubview() {
        NSLayoutConstraint.activate([
            contentSubview.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            contentSubview.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.9),
            contentSubview.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.07),
            contentSubview.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
        contentSubview.backgroundColor = .systemGray5
        contentSubview.layer.cornerRadius = 15
        contentSubview.addSubview(backButton)
        contentSubview.addSubview(searchTF)
    }
    
    private func setupBackButton() {
        NSLayoutConstraint.activate([
            backButton.centerYAnchor.constraint(equalTo: contentSubview.centerYAnchor),
            backButton.leadingAnchor.constraint(equalTo: contentSubview.leadingAnchor),
            backButton.heightAnchor.constraint(equalTo: contentSubview.heightAnchor),
            backButton.widthAnchor.constraint(equalTo: backButton.heightAnchor)
        ])
        backButton.backgroundColor = .systemGray5
        backButton.layer.cornerRadius = 15
        backButton.setImage(UIImage(systemName: "chevron.backward"), for: .normal)
        backButton.tintColor = .systemGray
        backButton.addTarget(self, action: #selector(goBack), for: .touchUpInside)
    }
    
    
    private func setupSearchTF() {
        NSLayoutConstraint.activate([
            searchTF.centerYAnchor.constraint(equalTo: contentSubview.centerYAnchor),
            searchTF.trailingAnchor.constraint(equalTo: contentSubview.trailingAnchor),
            searchTF.leadingAnchor.constraint(equalTo: backButton.trailingAnchor),
            searchTF.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.07),
        ])
        searchTF.backgroundColor = .systemGray5
        searchTF.layer.cornerRadius = 15
        searchTF.attributedPlaceholder = NSAttributedString(string: "Выберете место",
                                                            attributes: [NSAttributedString.Key.foregroundColor: UIColor.systemGray])
        searchTF.font = .boldSystemFont(ofSize: 16)
        searchTF.textColor = .black
        searchTF.textAlignment = .left
        searchTF.addTarget(self, action: #selector(textFieldDidChange(_:)),
                           for: .editingChanged)
        searchTF.addTarget(self, action: #selector(textFieldHasBeenActivated), for: .touchDown)
        searchTF.delegate = self
    }
    
    private func setupMapView() {
        NSLayoutConstraint.activate([
            mapView.topAnchor.constraint(equalTo: navigationSubview.bottomAnchor),
            mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        mapView.showsBuildings = true
        mapView.showsUserLocation = true
    }
    
    private func setupTableView() {
        NSLayoutConstraint.activate([
            placesTableView.topAnchor.constraint(equalTo: navigationSubview.bottomAnchor),
            placesTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            placesTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            placesTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        placesTableView.isHidden = true
        placesTableView.backgroundColor = .white
        placesTableView.alpha = 0.0
        placesTableView.separatorStyle = .none
    }
    
    private func setupProceedButton() {
        NSLayoutConstraint.activate([
            proceedButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            proceedButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -25),
            proceedButton.heightAnchor.constraint(equalTo: backButton.heightAnchor),
            proceedButton.widthAnchor.constraint(equalTo: proceedButton.heightAnchor)
        ])
        proceedButton.backgroundColor = .clear
        proceedButton.setImage(UIImage(systemName: "arrow.forward.circle.fill"), for: .normal)
        proceedButton.tintColor = .lightBlue
        proceedButton.imageView?.contentMode = .scaleAspectFit
        proceedButton.contentHorizontalAlignment = UIControl.ContentHorizontalAlignment.fill
        proceedButton.contentVerticalAlignment = UIControl.ContentVerticalAlignment.fill
        proceedButton.isHidden = true
        proceedButton.addTarget(self, action: #selector(sendCoordinatesToRideSearchVC), for: .touchUpInside)
    }
    
    deinit {
        print("deallocating\(self)")
    }
    
}


