//
//  MapViewController.swift
//  RideIn
//
//  Created by Алекс Ломовской on 14.04.2021.
//

import UIKit
import MapKit

class MapViewController: UIViewController {

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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(navigationSubview)
        view.addSubview(mapView)
        view.addSubview(contentSubview)
        
        setupView()
        setupNavigationView()
        setupContentSubview()
        setupMapView()
        setupBackButton()
        setupSearchTF()
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
        
    }
    


    
    deinit {
        print("deallocating\(self)")
    }
    
}

//MARK:- UITextFieldDelegate
extension MapViewController: UITextFieldDelegate {
    
    @objc final func textFieldDidChange(_ textField: UITextField) {
        
    }
    
    @objc func textFieldHasBeenActivated(textField: UITextField) {
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
}

//MARK: - HelpingMethods
extension MapViewController {
    
    @objc final func goBack() {
        navigationController?.popViewController(animated: true)
    }
    
}
