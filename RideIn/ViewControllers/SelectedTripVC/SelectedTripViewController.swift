//
//  SelectedTripViewController.swift
//  RideIn
//
//  Created by Алекс Ломовской on 21.04.2021.
//

import UIKit
import MapKit

final class SelectedTripViewController: UIViewController {
    
    /// Coordinator
    weak var coordinator: Coordinator?
    
    lazy var controllerDataProvider = makeControllerDataProvider()
    
    /// Is triggered when user tap the showMapButton
    var onMapSelected: ((_ placeType: PlaceType, _ selectedTrip: Trip? ) -> Void)?
    
    /// Triggered when vc is ready to be closed
    var onFinish: CompletionBlock?
    
    
    //MARK: UIElements -
    let departurePlaceMapButton = UIButton.createDefaultButton()
    
    let destinationPlaceMapButton = UIButton.createDefaultButton()
    
    private let navigationSubview = UIView.createDefaultView()
    
    private let backButton = UIButton.createDefaultButton()
    
    private let scrollView = UIScrollView.createDefaultScrollView()
    
    private let contentView = UIView.createDefaultView()
    
    private let topSubview = UIView.createDefaultView()
    
    private let dateLabel = UILabel.createDefaultLabel()
    
    private let departureTimeLabel = UILabel.createDefaultLabel()
    
    private let destinationTimeLabel = UILabel.createDefaultLabel()
    
    private let topCircle = UIImageView.createDefaultIV(withImage: UIImage(systemName: "circlebadge",
                                                                           withConfiguration: UIImage.SymbolConfiguration(weight: .bold)))
    
    private let lineView = UIView.createDefaultView()
    
    private let bottomCircle = UIImageView.createDefaultIV(withImage: UIImage(systemName: "circlebadge",
                                                                              withConfiguration: UIImage.SymbolConfiguration(weight: .bold)))
    
    private let departurePlaceLabel = UILabel.createDefaultLabel()
    
    private let destinationPlaceLabel = UILabel.createDefaultLabel()
    
    private let priceSubview = UIView.createDefaultView()
    
    private let passengersCountLabel = UILabel.createDefaultLabel()
    
    private let priceLabel = UILabel.createDefaultLabel()
    
    //MARK: viewDidLoad-
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(navigationSubview)
        view.addSubview(scrollView)
        
        setupView()
        setupNavigationController()
        setupNavigationSubview()
        setupBackButton()
        setupScrollView()
        setupContentView()
        setupTopSubview()
        setupDateLabel()
        setupDepatureTimeLabel()
        setupTopCircle()
        setupDeparturePlace()
        setupDepartureMapButton()
        setupLine()
        setupArrivingTimeLabel()
        setupBottomCircle()
        setupArrivingPlace()
        setupArrivingMapButton()
        setupPriceView()
        setupPassengersCountLabel()
        setupPriceLabel()
    }
    
    //MARK: UIMethods -
    private func setupView() {
        view.backgroundColor = .systemGray5
    }
    
    private func setupNavigationController() {
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    private func setupNavigationSubview() {
        NSLayoutConstraint.activate([
            navigationSubview.topAnchor.constraint(equalTo: view.topAnchor),
            navigationSubview.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            navigationSubview.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            navigationSubview.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: (view.frame.height * 0.08))
        ])
        navigationSubview.backgroundColor = .white
        navigationSubview.addSubview(backButton)
    }
    
    private func setupBackButton() {
        NSLayoutConstraint.activate([
            backButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            backButton.leadingAnchor.constraint(equalTo: navigationSubview.leadingAnchor, constant: 10),
            backButton.heightAnchor.constraint(equalTo: navigationSubview.heightAnchor, multiplier: 0.27),
            backButton.widthAnchor.constraint(equalTo: backButton.heightAnchor)
        ])
        backButton.setImage(UIImage(systemName:"arrow.backward"), for: .normal)
        backButton.tintColor = .lightBlue
        backButton.imageView?.contentMode = .scaleAspectFit
        backButton.contentVerticalAlignment = .fill
        backButton.contentHorizontalAlignment = .fill
        backButton.addTarget(self, action: #selector(backButtonPressed), for: .touchUpInside)
    }
    
    private func setupScrollView() {
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: navigationSubview.bottomAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)
        ])
        scrollView.addSubview(contentView)
    }
    
    private func setupContentView() {
        let heightConstraint = contentView.heightAnchor.constraint(equalTo: scrollView.safeAreaLayoutGuide.heightAnchor)
        heightConstraint.priority = UILayoutPriority(rawValue: 250)
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.safeAreaLayoutGuide.widthAnchor),
            heightConstraint
        ])
        contentView.addSubview(topSubview)
        contentView.addSubview(priceSubview)
    }
    
    private func setupTopSubview() {
        NSLayoutConstraint.activate([
            topSubview.topAnchor.constraint(equalTo: contentView.topAnchor),
            topSubview.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            topSubview.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            topSubview.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.4)
        ])
        topSubview.backgroundColor = .white
        topSubview.addSubview(dateLabel)
        topSubview.addSubview(departureTimeLabel)
        topSubview.addSubview(topCircle)
        topSubview.addSubview(departurePlaceLabel)
        topSubview.addSubview(departurePlaceMapButton)
        topSubview.addSubview(lineView)
        topSubview.addSubview(destinationTimeLabel)
        topSubview.addSubview(destinationPlaceMapButton)
        topSubview.addSubview(bottomCircle)
        topSubview.addSubview(destinationPlaceLabel)
        
    }
    
    private func setupDateLabel() {
        NSLayoutConstraint.activate([
            dateLabel.topAnchor.constraint(equalTo: topSubview.topAnchor, constant: 10),
            dateLabel.leadingAnchor.constraint(equalTo: topSubview.leadingAnchor, constant: 10),
            dateLabel.trailingAnchor.constraint(equalTo: topSubview.trailingAnchor, constant: -10)
        ])
        dateLabel.textColor = .darkGray
        dateLabel.font = .boldSystemFont(ofSize: 30)
        dateLabel.text = controllerDataProvider.date
    }
    
    private func setupDepatureTimeLabel() {
        NSLayoutConstraint.activate([
            departureTimeLabel.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 20),
            departureTimeLabel.leadingAnchor.constraint(equalTo: topSubview.leadingAnchor, constant: 10),
            departureTimeLabel.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.2)
        ])
        departureTimeLabel.text = controllerDataProvider.departureTime
        departureTimeLabel.textColor = .darkGray
        departureTimeLabel.font = .boldSystemFont(ofSize: 20)
    }
    
    private func setupTopCircle() {
        NSLayoutConstraint.activate([
            topCircle.centerYAnchor.constraint(equalTo: departureTimeLabel.centerYAnchor),
            topCircle.leadingAnchor.constraint(equalTo: departureTimeLabel.trailingAnchor, constant: 20),
            topCircle.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.05),
            topCircle.heightAnchor.constraint(equalTo: topCircle.widthAnchor, multiplier: 1.1)
        ])
        topCircle.tintColor = .darkGray
        topCircle.contentMode = .scaleToFill
    }
    
    private func setupDeparturePlace() {
        NSLayoutConstraint.activate([
            departurePlaceLabel.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 20),
            departurePlaceLabel.leadingAnchor.constraint(equalTo: topCircle.trailingAnchor, constant: 10),
            departurePlaceLabel.trailingAnchor.constraint(equalTo: departurePlaceMapButton.leadingAnchor, constant: -5)
        ])
        departurePlaceLabel.text = controllerDataProvider.departurePlace
        departurePlaceLabel.textColor = .darkGray
        departurePlaceLabel.font = .boldSystemFont(ofSize: 20)
        departurePlaceLabel.numberOfLines = 1
        departurePlaceLabel.clipsToBounds = true
    }
    
    private func setupDepartureMapButton() {
        NSLayoutConstraint.activate([
            departurePlaceMapButton.topAnchor.constraint(equalTo: departureTimeLabel.centerYAnchor),
            departurePlaceMapButton.trailingAnchor.constraint(equalTo: topSubview.trailingAnchor, constant: -10),
            departurePlaceMapButton.heightAnchor.constraint(equalTo: departureTimeLabel.heightAnchor),
            departurePlaceMapButton.widthAnchor.constraint(equalTo: departurePlaceMapButton.heightAnchor)
        ])
        departurePlaceMapButton.setImage(UIImage(systemName: "chevron.right"), for: .normal)
        departurePlaceMapButton.tintColor = .systemGray
        departurePlaceMapButton.imageView?.contentMode = .scaleAspectFit
        departurePlaceMapButton.contentVerticalAlignment = .fill
        departurePlaceMapButton.contentHorizontalAlignment = .fill
        departurePlaceMapButton.addTarget(self, action: #selector(showMapButtonTapped(sender:)), for: .touchUpInside)
    }
    
    private func setupLine() {
        NSLayoutConstraint.activate([
            lineView.topAnchor.constraint(equalTo: topCircle.bottomAnchor),
            lineView.bottomAnchor.constraint(equalTo: bottomCircle.topAnchor),
            lineView.centerXAnchor.constraint(equalTo: topCircle.centerXAnchor),
            lineView.widthAnchor.constraint(equalTo: topCircle.widthAnchor, multiplier: 0.3)
        ])
        lineView.backgroundColor = .darkGray
    }
    
    private func setupArrivingTimeLabel() {
        NSLayoutConstraint.activate([
            destinationTimeLabel.topAnchor.constraint(equalTo: topSubview.centerYAnchor, constant: 10),
            destinationTimeLabel.leadingAnchor.constraint(equalTo: departureTimeLabel.leadingAnchor),
            destinationTimeLabel.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.2)
        ])
        destinationTimeLabel.text = controllerDataProvider.arrivingTime
        destinationTimeLabel.textColor = .darkGray
        destinationTimeLabel.font = .boldSystemFont(ofSize: 20)
    }
    
    private func setupBottomCircle() {
        NSLayoutConstraint.activate([
            bottomCircle.centerYAnchor.constraint(equalTo: destinationTimeLabel.centerYAnchor),
            bottomCircle.centerXAnchor.constraint(equalTo: topCircle.centerXAnchor),
            bottomCircle.widthAnchor.constraint(equalTo: topCircle.widthAnchor),
            bottomCircle.heightAnchor.constraint(equalTo: bottomCircle.widthAnchor, multiplier: 1.1)
        ])
        bottomCircle.tintColor = .darkGray
        bottomCircle.contentMode = .scaleToFill
        
    }
    
    private func setupArrivingPlace() {
        NSLayoutConstraint.activate([
            destinationPlaceLabel.centerYAnchor.constraint(equalTo: bottomCircle.centerYAnchor),
            destinationPlaceLabel.leadingAnchor.constraint(equalTo: bottomCircle.trailingAnchor, constant: 10),
            destinationPlaceLabel.trailingAnchor.constraint(equalTo: destinationPlaceMapButton.leadingAnchor, constant: -5)
            
        ])
        destinationPlaceLabel.text = controllerDataProvider.destinationPlace
        destinationPlaceLabel.textColor = .darkGray
        destinationPlaceLabel.font = .boldSystemFont(ofSize: 20)
        destinationPlaceLabel.numberOfLines = 1
    }
    
    private func setupArrivingMapButton() {
        NSLayoutConstraint.activate([
            destinationPlaceMapButton.trailingAnchor.constraint(equalTo: topSubview.trailingAnchor, constant: -10),
            destinationPlaceMapButton.bottomAnchor.constraint(equalTo: destinationTimeLabel.centerYAnchor),
            destinationPlaceMapButton.heightAnchor.constraint(equalTo: destinationTimeLabel.heightAnchor),
            destinationPlaceMapButton.widthAnchor.constraint(equalTo: destinationPlaceMapButton.heightAnchor)
            
        ])
        destinationPlaceMapButton.setImage(UIImage(systemName: "chevron.right"), for: .normal)
        destinationPlaceMapButton.tintColor = .systemGray
        destinationPlaceMapButton.imageView?.contentMode = .scaleAspectFit
        destinationPlaceMapButton.contentVerticalAlignment = .fill
        destinationPlaceMapButton.contentHorizontalAlignment = .fill
        destinationPlaceMapButton.addTarget(self, action: #selector(showMapButtonTapped(sender:)), for: .touchUpInside)
    }
    
    private func setupPriceView() {
        NSLayoutConstraint.activate([
            priceSubview.topAnchor.constraint(equalTo: topSubview.bottomAnchor, constant: 10),
            priceSubview.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            priceSubview.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            priceSubview.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.1)
        ])
        priceSubview.backgroundColor = .white
        priceSubview.addSubview(passengersCountLabel)
        priceSubview.addSubview(priceLabel)
    }
    
    private func setupPassengersCountLabel() {
        NSLayoutConstraint.activate([
            passengersCountLabel.centerYAnchor.constraint(equalTo: priceSubview.centerYAnchor),
            passengersCountLabel.leadingAnchor.constraint(equalTo: priceSubview.leadingAnchor, constant: 10),
            passengersCountLabel.heightAnchor.constraint(equalTo: priceSubview.heightAnchor, multiplier: 0.4)
        ])
        passengersCountLabel.text = NSLocalizedString("TotalPrice", comment: "") + " " + "\(controllerDataProvider.passengersCount)" + " " + NSLocalizedString("Search.morePassengers", comment: "")
        passengersCountLabel.textColor = .systemGray3
        passengersCountLabel.font = .boldSystemFont(ofSize: 15)
    }
    
    private func setupPriceLabel() {
        NSLayoutConstraint.activate([
            priceLabel.centerYAnchor.constraint(equalTo: priceSubview.centerYAnchor),
            priceLabel.trailingAnchor.constraint(equalTo: priceSubview.trailingAnchor, constant: -10),
            priceLabel.heightAnchor.constraint(equalTo: priceSubview.heightAnchor, multiplier: 0.4)
        ])
        priceLabel.text = "\(controllerDataProvider.priceForOne * Float(controllerDataProvider.passengersCount))"
        priceLabel.textColor = .darkGray
        priceLabel.font = . boldSystemFont(ofSize: 20)
    }
    
    deinit {
        Log.i("deallocating \(self)")
    }
}

private extension SelectedTripViewController {
    func makeControllerDataProvider() -> SelectedTripViewControllerDataProvider {
        return MainControllerDataProviderFactory.makeProvider(for: self) as! SelectedTripViewControllerDataProvider
    }
}
