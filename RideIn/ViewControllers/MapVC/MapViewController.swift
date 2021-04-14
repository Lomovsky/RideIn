//
//  MapViewController.swift
//  RideIn
//
//  Created by Алекс Ломовской on 14.04.2021.
//

import UIKit
import MapKit

protocol HandleMapSearch {
    func dropPinZoomIn(placemark: MKPlacemark)
}


final class MapViewController: UIViewController {
    
    let locationManager = CLLocationManager()
    var timer: Timer?
    var matchingItems = [MKMapItem]()
    var textFieldTapped = false
    var selectedPin:MKPlacemark? = nil
    weak var rideSearchDelegate: RideSearchDelegate?
    
    
    let contentSubview: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let navigationSubview: UIView = {
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
        placesTableView.dataSource = self
        placesTableView.delegate = self
        
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
        
        view.addSubview(navigationSubview)
        view.addSubview(mapView)
        view.addSubview(contentSubview)
        view.addSubview(placesTableView)
        
        setupView()
        setupNavigationView()
        setupContentSubview()
        setupMapView()
        setupBackButton()
        setupSearchTF()
        setupTableView()
    }
    
    
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
    
    
    deinit {
        print("deallocating\(self)")
    }
    
}

//MARK:- UITextFieldDelegate
extension MapViewController: UITextFieldDelegate {
    
    @objc final func textFieldDidChange(_ textField: UITextField) {
        guard let text = textField.text, text != "" else { return }
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = text
        request.region = mapView.region
        let search = MKLocalSearch(request: request)
        
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: false, block: { [unowned self] (_) in
            search.start { response, _ in
                guard let response = response else {
                    return
                }
                self.matchingItems = response.mapItems
                self.placesTableView.reloadData()
            }
        })
    }

    
    @objc func textFieldHasBeenActivated(textField: UITextField) {
        animateTableView(toSelected: true)
        backButton.removeTarget(self, action: #selector(goBack), for: .touchUpInside)
        backButton.addTarget(self, action: #selector(dismissTableView), for: .touchUpInside)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        animateTableView(toSelected: false)
        return true
    }
    
}

//MARK: - HelpingMethods
extension MapViewController {
    
    @objc final func goBack() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc final func dismissTableView() {
        animateTableView(toSelected: false)
        searchTF.resignFirstResponder()
        backButton.removeTarget(self, action: #selector(dismissTableView), for: .touchUpInside)
        backButton.addTarget(self, action: #selector(goBack), for: .touchUpInside)
    }
    
    func animateTableView(toSelected state: Bool) {
        if state {
            textFieldTapped = true
            placesTableView.isHidden = false
            
            UIView.animate(withDuration: 0.3) {
                self.placesTableView.alpha = 1.0
            }
        } else {
            textFieldTapped = false
            UIView.animate(withDuration: 0.3) {
                self.placesTableView.alpha = 0.0
            }
            placesTableView.isHidden = true
            
        }
    }
    
    
    func parseAddress(selectedItem: MKPlacemark) -> String {
        // put a space between "4" and "Melrose Place"
        let firstSpace = (selectedItem.subThoroughfare != nil && selectedItem.thoroughfare != nil) ? " " : ""
        // put a comma between street and city/state
        let comma = (selectedItem.subThoroughfare != nil || selectedItem.thoroughfare != nil) && (selectedItem.subAdministrativeArea != nil || selectedItem.administrativeArea != nil) ? ", " : ""
        // put a space between "Washington" and "DC"
        let secondSpace = (selectedItem.subAdministrativeArea != nil && selectedItem.administrativeArea != nil) ? " " : ""
        let addressLine = String(
            format:"%@%@%@%@%@%@%@",
            // street number
            selectedItem.subThoroughfare ?? "",
            firstSpace,
            // street name
            selectedItem.thoroughfare ?? "",
            comma,
            // city
            selectedItem.locality ?? "",
            secondSpace,
            // state
            selectedItem.administrativeArea ?? ""
        )
        return addressLine
    }
    
}


//MARK:- CLLocationManagerDelegate
extension MapViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            locationManager.requestLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
            let region = MKCoordinateRegion(center: location.coordinate, span: span)
            mapView.setRegion(region, animated: true)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("error is \(error)")
    }
    
   
    
}

//MARK:- MKMapViewDelegate
extension MapViewController: MKMapViewDelegate {
    
}


//MARK:- TableViewDataSource & Delegate
extension MapViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return matchingItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: MapTableViewCell.reuseIdentifier, for: indexPath) as! MapTableViewCell
        
        let place = matchingItems[indexPath.row].placemark
        
        cell.textLabel?.text = place.name
        cell.detailTextLabel?.text = parseAddress(selectedItem: place)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let place = matchingItems[indexPath.row].placemark
        dropPinZoomIn(placemark: place)
        dismissTableView()
        
    }
    
}

extension MapViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return searchTF.frame.height
    }
}

extension MapViewController: HandleMapSearch {
    
    func dropPinZoomIn(placemark:MKPlacemark){
        // cache the pin
        selectedPin = placemark
        // clear existing pins
        mapView.removeAnnotations(mapView.annotations)
        let annotation = MKPointAnnotation()
        annotation.coordinate = placemark.coordinate
        annotation.title = placemark.name
        if let city = placemark.locality,
        let state = placemark.administrativeArea {
            annotation.subtitle = "\(city) \(state)"
        }
        mapView.addAnnotation(annotation)
        let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        let region = MKCoordinateRegion(center: placemark.coordinate, span: span)
        mapView.setRegion(region, animated: true)
    }
}
