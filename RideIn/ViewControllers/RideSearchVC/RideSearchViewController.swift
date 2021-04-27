//
//  ViewController.swift
//  RideIn
//
//  Created by Алекс Ломовской on 12.04.2021.
//

import UIKit
import MapKit

final class RideSearchViewController: UIViewController {
    
    //MARK: Declarations -
    ///Alerting user that there are no trips available
    lazy var alertController = makeAlert()
    
    ///The factory to make url with different request parameters
    lazy var urlFactory = makeURLFactory()
    
    ///Simply the network manager
    lazy var networkManager = makeNetworkManager()
    
    ///Location manager to request user location and proceed place search requests
    lazy var locationManager = makeLocationManager()
    
    ///Constraint factory made for simplifying textFields animations
    lazy var constraintFactory = makeConstrainFactory()
    
    ///The array of objects we receive after sending URL request with departure, destination and other parameters
    var trips = [Trip]()

    ///The array of items that match to users search
    var matchingItems = [MKMapItem]()
    
    ///Current user region in which to search locations
    var region = MKCoordinateRegion()
        
    ///Timer for limiting search requests
    var timer: Timer?

    
    ///Departure point location to be selected on mapVC
    var departureCLLocation = CLLocation()
    
    ///Departure point coordinates to be selected on mapVC
    var departureCoordinates = String()
    
    ///Destination point coordinates to be selected on mapVC
    var destinationCoordinates = String()
    
    
    ///The constraints to configure animations
    var destinationContentSubviewTopConstraint = NSLayoutConstraint()
    var destinationTFTopConstraint = NSLayoutConstraint()
    var tableViewSubviewTopConstraint = NSLayoutConstraint()
    
    ///The type we work with (departure or destination) to configure methods and data transferring between ViewControllers
    var placeType: PlaceType?
    
    ///The textField which has been selected
    var chosenTF = UITextField()
    
    ///Properties that displays selection state for textField to prevent multiple animations
    var departureTextFieldTapped = false
    var destinationTextFieldTapped = false
    
    
    ///Property for configuring navigationController isHidden state due to gestureRecognizer
    var shouldNavigationControllerBeHiddenAnimated = (hidden: Bool(), animated: Bool())
    
    
    ///Current date or the date user chose to send as request parameter
    var date: String? = nil
    
    ///Number of passengers to send as request parameter
    var passengersCount = 1
    
    ///This property is used for configuring the declension of the word "Пассажир" due to number of passengers
    var passengerDeclension: Declensions {
            if passengersCount == 1 {
                return .one
            } else if passengersCount < 4, passengersCount > 1 {
                return .two
            } else {
                return .more
            }
    }
    
    //MARK: UIElements -
    let departureContentSubview = UIView.createDefaultView()
    
    let departureBackButton = UIButton.createDefaultButton()
    
    let departureTextField = UITextField.createDefaultTF()
    
    let destinationContentSubview = UIView.createDefaultView()
    
    let destinationBackButton = UIButton.createDefaultButton()
    
    let destinationTextField = UITextField.createDefaultTF()
    
    let tableViewSubview = UIView.createDefaultView()
    
    let showMapSubview = UIView.createDefaultView()
    
    let mapImageView = UIImageView.createDefaultIV(withImage: nil)
    
    let showMapButton = UIButton.createDefaultButton()
    
    let arrowImageview = UIImageView.createDefaultIV(withImage: nil)
    
    let topLine = UIView.createDefaultView()
    
    let dateView = UIView.createDefaultView()
    
    let passengersButton = UIButton.createDefaultButton()
    
    let bottomLine = UIView.createDefaultView()
    
    let searchButton = UIButton.createDefaultButton()
    
    let mapView = MKMapView.createDefaultMapView()

    let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView()
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()
    
    let datePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.translatesAutoresizingMaskIntoConstraints = false
        return picker
    }()
    
    let searchTableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(RideSearchTableViewCell.self, forCellReuseIdentifier: RideSearchTableViewCell.reuseIdentifier)
        return tableView
    }()
    
   
    
    //MARK: viewDidLoad -
    override func viewDidLoad() {
        super.viewDidLoad()
        searchTableView.dataSource = self
        searchTableView.delegate = self
        
        view.addSubview(departureContentSubview)
        view.addSubview(destinationContentSubview)
        view.addSubview(destinationTextField)
        view.addSubview(topLine)
        view.addSubview(dateView)
        view.addSubview(passengersButton)
        view.addSubview(bottomLine)
        view.addSubview(searchButton)
        view.addSubview(activityIndicator)
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
        setupDateView()
        setupDatePicker()
        setupPassengerButton()
        setupBottomLine()
        setupSearchButton()
        setupActivityIndicator()
        setupTableViewSubview()
        setupMapSubview()
        setupMapImageView()
        setupShowMapButton()
        setupArrowImageView()
        setupSearchTableView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        navigationController?.interactivePopGestureRecognizer?.removeTarget(self, action: #selector(navigationGestureRecognizerTriggered))
    }
    
    
    //MARK: UIMethods -
    private func setupView() {
        view.backgroundColor = .white
    }
    
    private func setupNavigationController() {
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.visibleViewController?.title = "Поиск поездки"
        navigationController?.navigationBar.largeTitleTextAttributes = [.foregroundColor: UIColor.darkGray]
        navigationController?.setNavigationBarHidden(false, animated: true)
        navigationController?.interactivePopGestureRecognizer?.delegate = self
    }
    
    private func setupFromContentSubview() {
        NSLayoutConstraint.activate([
            departureContentSubview.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 30),
            departureContentSubview.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.9),
            departureContentSubview.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.07),
            departureContentSubview.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
        departureContentSubview.backgroundColor = .systemGray5
        departureContentSubview.layer.cornerRadius = 15
        departureContentSubview.addSubview(departureBackButton)
        departureContentSubview.addSubview(departureTextField)
    }
    
    private func setupFromBackButton() {
        NSLayoutConstraint.activate([
            departureBackButton.centerYAnchor.constraint(equalTo: departureContentSubview.centerYAnchor),
            departureBackButton.leadingAnchor.constraint(equalTo: departureContentSubview.leadingAnchor),
            departureBackButton.heightAnchor.constraint(equalTo: departureContentSubview.heightAnchor),
            departureBackButton.widthAnchor.constraint(equalTo: departureContentSubview.heightAnchor)
        ])
        departureBackButton.backgroundColor = .clear
        departureBackButton.layer.cornerRadius = 15
        departureBackButton.setImage(UIImage(systemName: "chevron.backward"), for: .normal)
        departureBackButton.tintColor = .systemGray
        departureBackButton.isHidden = true
        departureBackButton.addTarget(self, action: #selector(dismissDepartureTextField), for: .touchUpInside)
    }
    
    private func setupFromTF() {
        NSLayoutConstraint.activate([
            departureTextField.centerYAnchor.constraint(equalTo: departureContentSubview.centerYAnchor),
            departureTextField.trailingAnchor.constraint(equalTo: departureContentSubview.trailingAnchor),
            departureTextField.leadingAnchor.constraint(equalTo: departureBackButton.trailingAnchor),
            departureTextField.heightAnchor.constraint(equalTo: departureContentSubview.heightAnchor),
        ])
        departureTextField.backgroundColor = .clear
        departureTextField.layer.cornerRadius = 15
        departureTextField.attributedPlaceholder = NSAttributedString(string: "Выезжаете из",
                                                                 attributes: [NSAttributedString.Key.foregroundColor: UIColor.systemGray])
        departureTextField.font = .boldSystemFont(ofSize: 16)
        departureTextField.textColor = .black
        departureTextField.textAlignment = .left
        departureTextField.addTarget(self, action: #selector(textFieldDidChange(_:)),
                                for: .editingChanged)
        departureTextField.addTarget(self, action: #selector(textFieldHasBeenActivated), for: .touchDown)
        departureTextField.delegate = self
        departureTextField.clearButtonMode = .always
    }
    
    private func setupToContentSubview() {
        destinationContentSubviewTopConstraint = NSLayoutConstraint(item: destinationContentSubview, attribute: .top,
                                                           relatedBy: .equal, toItem: view.safeAreaLayoutGuide,
                                                           attribute: .top, multiplier: 1,
                                                           constant: 45 + (view.frame.height * 0.07))
        
        NSLayoutConstraint.activate([
            destinationContentSubviewTopConstraint,
            destinationContentSubview.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.9),
            destinationContentSubview.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.07),
            destinationContentSubview.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
        
        destinationContentSubview.backgroundColor = .systemGray5
        destinationContentSubview.layer.cornerRadius = 15
        destinationContentSubview.addSubview(destinationBackButton)
        destinationContentSubview.addSubview(destinationTextField)
    }
    
    private func setupToBackButton() {
        NSLayoutConstraint.activate([
            destinationBackButton.centerYAnchor.constraint(equalTo: destinationContentSubview.centerYAnchor),
            destinationBackButton.leadingAnchor.constraint(equalTo: destinationContentSubview.leadingAnchor),
            destinationBackButton.heightAnchor.constraint(equalTo: destinationContentSubview.heightAnchor),
            destinationBackButton.widthAnchor.constraint(equalTo: destinationContentSubview.heightAnchor)
        ])
        destinationBackButton.backgroundColor = .clear
        destinationBackButton.layer.cornerRadius = 15
        destinationBackButton.setImage(UIImage(systemName: "chevron.backward"), for: .normal)
        destinationBackButton.tintColor = .systemGray
        destinationBackButton.isHidden = true
        destinationBackButton.addTarget(self, action: #selector(dismissDestinationTextField), for: .touchUpInside)
    }
    
    private func setupToTF() {
        destinationTFTopConstraint = NSLayoutConstraint(item: destinationTextField, attribute: .top,
                                               relatedBy: .equal, toItem: view.safeAreaLayoutGuide,
                                               attribute: .top, multiplier: 1,
                                               constant: 45 + (view.frame.height * 0.07))
        NSLayoutConstraint.activate([
            destinationTFTopConstraint,
            destinationTextField.trailingAnchor.constraint(equalTo: destinationContentSubview.trailingAnchor),
            destinationTextField.leadingAnchor.constraint(equalTo: destinationBackButton.trailingAnchor),
            destinationTextField.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.07),
        ])
        
        destinationTextField.backgroundColor = .clear
        destinationTextField.layer.cornerRadius = 15
        destinationTextField.attributedPlaceholder = NSAttributedString(string: "Направляетесь в",
                                                               attributes: [NSAttributedString.Key.foregroundColor: UIColor.systemGray])
        destinationTextField.font = .boldSystemFont(ofSize: 16)
        destinationTextField.textColor = .black
        destinationTextField.textAlignment = .left
        destinationTextField.addTarget(self, action: #selector(textFieldDidChange(_:)),
                              for: .editingChanged)
        destinationTextField.addTarget(self, action: #selector(textFieldHasBeenActivated), for: .touchDown)
        destinationTextField.delegate = self
        destinationTextField.clearButtonMode = .always
    }
    
    private func setupTopLine() {
        NSLayoutConstraint.activate([
            topLine.topAnchor.constraint(equalTo: destinationContentSubview.bottomAnchor, constant: 20),
            topLine.leadingAnchor.constraint(equalTo: destinationContentSubview.leadingAnchor),
            topLine.trailingAnchor.constraint(equalTo: destinationContentSubview.trailingAnchor),
            topLine.heightAnchor.constraint(equalTo: destinationContentSubview.heightAnchor, multiplier: 0.02)
        ])
        topLine.backgroundColor = .systemGray5
    }
    
    private func setupDateView() {
        NSLayoutConstraint.activate([
            dateView.topAnchor.constraint(equalTo: topLine.bottomAnchor, constant: 20),
            dateView.leadingAnchor.constraint(equalTo: topLine.leadingAnchor),
            dateView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.3),
            dateView.heightAnchor.constraint(equalTo: passengersButton.heightAnchor)
        ])
        dateView.backgroundColor = .clear
        dateView.addSubview(datePicker)
    }
    
    private func setupDatePicker() {
        datePicker.frame = dateView.frame
        datePicker.calendar = .autoupdatingCurrent
        datePicker.datePickerMode = .date
        datePicker.addTarget(self, action: #selector(changeDateWith(sender:)), for: .valueChanged)
    }
    
    private func setupPassengerButton() {
        NSLayoutConstraint.activate([
            passengersButton.topAnchor.constraint(equalTo: topLine.bottomAnchor, constant: 20),
            passengersButton.leadingAnchor.constraint(equalTo: view.centerXAnchor, constant: 15)
        ])
        setPassengersCountWithDeclension()
        passengersButton.backgroundColor = .clear
        passengersButton.setTitleColor(.lightBlue, for: .normal)
        passengersButton.titleLabel?.font = .boldSystemFont(ofSize: 16)
        passengersButton.addTarget(self, action: #selector(passengersCountButtonTapped), for: .touchUpInside)
    }
    
    private func setupBottomLine() {
        NSLayoutConstraint.activate([
            bottomLine.topAnchor.constraint(equalTo: passengersButton.bottomAnchor, constant: 20),
            bottomLine.leadingAnchor.constraint(equalTo: destinationContentSubview.leadingAnchor),
            bottomLine.trailingAnchor.constraint(equalTo: destinationContentSubview.trailingAnchor),
            bottomLine.heightAnchor.constraint(equalTo: destinationContentSubview.heightAnchor, multiplier: 0.02)
        ])
        bottomLine.backgroundColor = .systemGray5
    }
    
    private func setupSearchButton() {
        NSLayoutConstraint.activate([
            searchButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            searchButton.topAnchor.constraint(equalTo: bottomLine.bottomAnchor, constant: 20),
            searchButton.heightAnchor.constraint(equalTo: departureContentSubview.heightAnchor, multiplier: 0.9),
            searchButton.widthAnchor.constraint(equalTo: departureContentSubview.widthAnchor, multiplier: 0.4)
        ])
        searchButton.setTitle("Искать", for: .normal)
        searchButton.isHidden = true
        searchButton.backgroundColor = .lightBlue
        searchButton.layer.cornerRadius = 25
        searchButton.titleLabel?.font = .boldSystemFont(ofSize: 20)
        searchButton.addTarget(self, action: #selector(searchButtonTapped), for: .touchUpInside)
    }
    
    private func setupActivityIndicator() {
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: searchButton.centerYAnchor)
        ])
        activityIndicator.isHidden = true
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
        showMapButton.addTarget(self, action: #selector(showMapButtonTapped), for: .touchUpInside)
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
    
    private func setupAlertController() {
        
    }
    
    deinit {
        print("deallocating\(self)")
    }
    
}

//MARK:- Factory methods
private extension RideSearchViewController {
    
    func makeNetworkManager() -> NetworkManager {
        return MainNetworkManager()
    }
    
    func makeURLFactory() -> URLFactory {
        return MainURLFactory()
    }
    
    func makeLocationManager() -> CLLocationManager {
        let manager = CLLocationManager()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.requestWhenInUseAuthorization()
        manager.requestLocation()
        return manager
    }
    
    func makeConstrainFactory() -> MainConstraintFactory {
        let factory = MainConstraintFactory(view: view, destinationContentSubview: destinationContentSubview,
                                        destinationTextField: destinationTextField, tableViewSubview: tableViewSubview)
        return factory
    }
    
    func makeAlert() -> UIAlertController {
        let alert = UIAlertController(title: "", message: "", preferredStyle: .alert)
        let dismissButton = UIAlertAction(title: "Отмена", style: .cancel) { (_) in
            self.dismiss(animated: true)
        }
        alert.addAction(dismissButton)
        return alert
    }
}
