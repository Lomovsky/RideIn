//
//  MapViewController.swift
//  RideIn
//
//  Created by Алекс Ломовской on 14.04.2021.
//

import UIKit
import MapKit


final class MapViewController: UIViewController {
    
    //MARK:- Declarations
    /// Coordinator
    weak var coordinator: Coordinator?
    
    /// The data provider of the viewController
    lazy var controllerDataProvider = makeViewControllerDataProvider()
    
    /// Is triggered when alert need to be shown
    var onAlert: CompletionBlock?
    
    /// Triggered when vc is ready to be closed
    var onFinish: CompletionBlock?
    
    
    /// The RideSearchVC delegate
    weak var rideSearchDelegate: RideSearchDelegate?
    
    //MARK: UIElements-
    let navigationSubview = UIView.createDefaultView()
    
    let contentSubview = UIView.createDefaultView()
    
    let backButton = UIButton.createDefaultButton()
    
    let searchTF = UITextField.createDefaultTF()
    
    let mapView = MKMapView.createDefaultMapView()
    
    let proceedButton = UIButton.createDefaultButton()
    
    let distanceSubview = UIView.createDefaultView()
    
    let distanceLabel = UILabel.createDefaultLabel()
    
    let focusOnUserLocationButton = UIButton.createDefaultButton()
    
    let focusOnUserLocationImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(systemName: "circle.fill")
        imageView.tintColor = .white
        return imageView
    }()
    
    let placesTableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(MapTableViewCell.self,
                           forCellReuseIdentifier: MapTableViewCell.reuseIdentifier)
        return tableView
    }()
    
    
    //MARK: viewDidLoad -
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = controllerDataProvider.mapKitDataProvider
        placesTableView.dataSource = controllerDataProvider.tableViewDataProvider
        placesTableView.delegate = controllerDataProvider.tableViewDataProvider
        
        view.addSubview(navigationSubview)
        view.addSubview(contentSubview)
        view.addSubview(mapView)
        view.addSubview(proceedButton)
        view.addSubview(focusOnUserLocationImageView)
        view.addSubview(focusOnUserLocationButton)
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
        setupFocusOnUserLocationImageView()
        setupFocusOnUserLocationButton()
        setupDistanceSubView()
        setupDistanceLabel()
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
        backButton.backgroundColor = .clear
        backButton.layer.cornerRadius = 15
        backButton.setImage(UIImage(systemName: "chevron.backward"), for: .normal)
        backButton.tintColor = .systemGray
        backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
    }
    
    
    private func setupSearchTF() {
        NSLayoutConstraint.activate([
            searchTF.centerYAnchor.constraint(equalTo: contentSubview.centerYAnchor),
            searchTF.trailingAnchor.constraint(equalTo: contentSubview.trailingAnchor),
            searchTF.leadingAnchor.constraint(equalTo: backButton.trailingAnchor),
            searchTF.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.07),
        ])
        searchTF.backgroundColor = .clear
        searchTF.layer.cornerRadius = 15
        searchTF.attributedPlaceholder = NSAttributedString(string: NSLocalizedString("MapVC.searchPlaceholder", comment: ""),
                                                            attributes: [NSAttributedString.Key.foregroundColor: UIColor.systemGray])
        searchTF.font = .boldSystemFont(ofSize: 16)
        searchTF.textColor = .black
        searchTF.textAlignment = .left
        if controllerDataProvider.textFieldActivationObserverEnabled {
            searchTF.addTarget(self, action: #selector(textFieldDidChange(_:)),
                               for: .editingChanged)
            searchTF.addTarget(self, action: #selector(textFieldHasBeenActivated), for: .touchDown)
            searchTF.isEnabled = true
        } else {
            searchTF.isEnabled = false
        }
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
        mapView.addSubview(distanceSubview)
        
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
        proceedButton.addTarget(self, action: #selector(proceedButtonTapped), for: .touchUpInside)
    }
    
    private func setupDistanceSubView() {
        NSLayoutConstraint.activate([
            distanceSubview.topAnchor.constraint(equalTo: mapView.topAnchor),
            distanceSubview.leadingAnchor.constraint(equalTo: mapView.leadingAnchor),
            distanceSubview.trailingAnchor.constraint(equalTo: mapView.trailingAnchor),
            distanceSubview.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.04)
        ])
        distanceSubview.setBlurBackground()
        distanceSubview.addSubview(distanceLabel)
        distanceSubview.isHidden = controllerDataProvider.distanceSubviewIsHidden
    }
    
    private func setupDistanceLabel() {
        NSLayoutConstraint.activate([
            distanceLabel.centerXAnchor.constraint(equalTo: distanceSubview.centerXAnchor),
            distanceLabel.centerYAnchor.constraint(equalTo: distanceSubview.centerYAnchor)
        ])
        distanceLabel.textAlignment = .center
        distanceLabel.textColor = .systemGray
        distanceLabel.font = .boldSystemFont(ofSize: 20)
        distanceLabel.text = NSLocalizedString("MapVC.distance", comment: "") + ": " + "\(controllerDataProvider.mapKitDataProvider.distance)" + " " + NSLocalizedString("MapVC.km", comment: "")
        
    }
    
    private func setupFocusOnUserLocationImageView() {
        NSLayoutConstraint.activate([
            focusOnUserLocationImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            focusOnUserLocationImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -15),
            focusOnUserLocationImageView.heightAnchor.constraint(equalTo: proceedButton.heightAnchor, multiplier: 0.7),
            focusOnUserLocationImageView.widthAnchor.constraint(equalTo: focusOnUserLocationImageView.heightAnchor)
        ])
    }
    
    private func setupFocusOnUserLocationButton() {
        NSLayoutConstraint.activate([
            focusOnUserLocationButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            focusOnUserLocationButton.centerXAnchor.constraint(equalTo: focusOnUserLocationImageView.centerXAnchor),
            focusOnUserLocationButton.heightAnchor.constraint(equalTo: proceedButton.heightAnchor, multiplier: 0.5),
            focusOnUserLocationButton.widthAnchor.constraint(equalTo: focusOnUserLocationButton.heightAnchor)
        ])
        focusOnUserLocationButton.setImage(UIImage(systemName: "location.circle.fill"), for: .normal)
        focusOnUserLocationButton.backgroundColor = .clear
        focusOnUserLocationButton.imageView?.contentMode = .scaleAspectFit
        focusOnUserLocationButton.contentHorizontalAlignment = UIControl.ContentHorizontalAlignment.fill
        focusOnUserLocationButton.contentVerticalAlignment = UIControl.ContentVerticalAlignment.fill
        focusOnUserLocationButton.addTarget(self, action: #selector(userLocationButtonTapped), for: .touchUpInside)
        focusOnUserLocationButton.setTitleColor(.lightBlue, for: .normal)
        focusOnUserLocationButton.setTitleColor(.systemGray4, for: .disabled)
    }
    
    deinit {
        Log.i("deallocating\(self)")
    }
    
}

private extension MapViewController {
    
    func makeViewControllerDataProvider() -> MapViewControllerDataProvider {
        return MainControllerDataProviderFactory.makeProvider(for: self) as! MapViewControllerDataProvider
    }
}
