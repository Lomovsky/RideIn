//
//  ViewController.swift
//  RideIn
//
//  Created by Алекс Ломовской on 12.04.2021.
//

import UIKit
import MapKit

protocol RideSearchDelegate: AnyObject {
  func changePassengersCount(with operation: Operation)
  func getPassengersCount() -> String
  func setCoordinates(with placemark: MKPlacemark, forPlace placeType: PlaceType)
  func setNavigationControllerHidden(to state: Bool, animated: Bool)
}

//MARK:- RideSearchViewController
final class RideSearchViewController: UIViewController {
  /// The data provider of the viewController
  lazy var controllerDataProvider = makeViewControllerDataProvider()
  
  /// Notifications manager
  lazy var notifications = makeNotificationsController()
  
  /// Is triggered when user tap on showMap button
  var onMapSelected: ((PlaceType?, RideSearchDelegate) -> Void)?
  
  /// Is triggered when user tap passengersCount button
  var onChoosePassengersCountSelected: ItemCompletionBlock<RideSearchDelegate>?
  
  /// Is triggered when user tap search button
  var onDataPrepared: ItemCompletionBlock<PreparedTripsDataModelFromSearchVC>?
  
  /// Is triggered when viewController needs to present alert
  var onAlert: ItemCompletionBlock<String>?
  
  /// Is triggered when controller is ready to be closed
  var onFinish: CompletionBlock?
  
  /// The constraint to configure animations
  var destinationContentSubviewTopConstraint = NSLayoutConstraint()
  
  /// The constraint to configure animations
  var destinationTFTopConstraint = NSLayoutConstraint()
  
  /// The constraint to configure animations
  var tableViewSubviewTopConstraint = NSLayoutConstraint()
  
  /// This property represents should the textfield become first responder after viewController is being loaded or not
  var shouldBecomeResponderOnLoad = false
  
  //MARK: UIElements -
  let departureContentSubview = UIView.createDefaultView()
  let departureBackButton = UIButton.createDefaultButton()
  let departureTextField = UITextField.createDefaultTF()
  let destinationContentSubview = UIView.createDefaultView()
  let destinationBackButton = UIButton.createDefaultButton()
  let destinationTextField = UITextField.createDefaultTF()
  let tableViewSubview = UIView.createDefaultView()
  let showMapSubview = UIView.createDefaultView()
  let mapImageView = UIImageView.createDefaultIV()
  let showMapButton = UIButton.createDefaultButton()
  let arrowImageview = UIImageView.createDefaultIV()
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
    tableView.register(RideSearchTableViewCell.self,
                       forCellReuseIdentifier: RideSearchTableViewCell.reuseIdentifier)
    return tableView
  }()
  
  
  
  //MARK: viewDidLoad -
  override func viewDidLoad() {
    super.viewDidLoad()
    searchTableView.dataSource = controllerDataProvider.tableViewDataProvider
    searchTableView.delegate = controllerDataProvider.tableViewDataProvider
    controllerDataProvider.tableViewDataProvider.parentVC = self
    
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
  
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    configureSubviews()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    changeSelectionState(with: shouldBecomeResponderOnLoad)
  }
  
  //MARK: UIMethods -
  private func setupView() {
    view.backgroundColor = .white
  }
  
  private func setupNavigationController() {
    navigationController?.navigationBar.prefersLargeTitles = true
    navigationController?.visibleViewController?.title = NSLocalizedString(.Localization.Search.title, comment: "")
    navigationController?.navigationBar.largeTitleTextAttributes = [.foregroundColor: UIColor.darkGray]
    navigationController?.navigationBar.isHidden = false
    
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
    departureTextField.attributedPlaceholder = NSAttributedString(string: NSLocalizedString(.Localization.Search.departure, comment: ""),
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
    destinationContentSubviewTopConstraint = NSLayoutConstraint(
      item: destinationContentSubview, attribute: .top,
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
    destinationTextField.attributedPlaceholder = NSAttributedString(string: NSLocalizedString(.Localization.Search.destination, comment: ""),
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
    searchButton.setTitle(NSLocalizedString(.Localization.Search.searchButton, comment: ""), for: .normal)
    searchButton.isHidden = true
    searchButton.backgroundColor = .lightBlue
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
    showMapButton.setTitle(NSLocalizedString(.Localization.Search.showMap, comment: ""), for: .normal)
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
  
  private func configureSubviews() {
    searchButton.layer.cornerRadius = searchButton.frame.height / 2
  }
  
}

//MARK:- Factory methods
private extension RideSearchViewController {
  
  func makeViewControllerDataProvider() -> RideSearchViewControllerDataProvider {
    return MainControllerDataProviderFactory.makeProvider(for: self) as! RideSearchViewControllerDataProvider
  }
  
  func makeNotificationsController() -> NotificationsController {
    return MainNotificationsController()
  }
}


