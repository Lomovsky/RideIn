//
//  SelectedTripViewController.swift
//  RideIn
//
//  Created by Алекс Ломовской on 21.04.2021.
//

import UIKit

final class SelectedTripViewController: UIViewController {
    
    var selectedTrip: Trip?
    
    var date = String()
    
    var departureTime = String()
    var departurePlace = String()
    var arrivingTime = String()
    var arrivingPlace = String()
    
    var passengersCount = Int()
    var priceForOne = Float()
    
    //MARK: UIElements -
    private let navigationSubview: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let backButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let scrollView: UIScrollView = {
        let scroll = UIScrollView()
        scroll.translatesAutoresizingMaskIntoConstraints = false
        return scroll
    }()
    
    private let contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let topSubview: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let departureTimeLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let arrivingTimeLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let topCircle: UIImageView = {
        let image = UIImageView()
        image.translatesAutoresizingMaskIntoConstraints = false
        let circleImage = UIImage(systemName: "circlebadge",
                                  withConfiguration: UIImage.SymbolConfiguration(weight: .bold))
        image.image = circleImage
        return image
    }()
    
    private let lineView: UIView = {
        let line = UIView()
        line.translatesAutoresizingMaskIntoConstraints = false
        return line
    }()
    
    private let bottomCircle: UIImageView = {
        let image = UIImageView()
        image.translatesAutoresizingMaskIntoConstraints = false
        let circleImage = UIImage(systemName: "circlebadge",
                                  withConfiguration: UIImage.SymbolConfiguration(weight: .bold))
        image.image = circleImage
        return image
    }()
    
    private let departurePlaceLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let departurePlaceMapButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let arrivingPlaceLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let arrivingPlaceMapButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let priceSubview: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let passengersCountLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let priceLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

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
        view.backgroundColor = .systemGray4
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
        backButton.addTarget(self, action: #selector(goBack), for: .touchUpInside)
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
        topSubview.addSubview(arrivingTimeLabel)
        topSubview.addSubview(arrivingPlaceMapButton)
        topSubview.addSubview(bottomCircle)
        topSubview.addSubview(arrivingPlaceLabel)

    }
    
    private func setupDateLabel() {
        NSLayoutConstraint.activate([
            dateLabel.topAnchor.constraint(equalTo: topSubview.topAnchor, constant: 10),
            dateLabel.leadingAnchor.constraint(equalTo: topSubview.leadingAnchor, constant: 10),
            dateLabel.trailingAnchor.constraint(equalTo: topSubview.trailingAnchor, constant: -10)
        ])
        dateLabel.textColor = .darkGray
        dateLabel.font = .boldSystemFont(ofSize: 30)
        dateLabel.text = date
    }
    
    private func setupDepatureTimeLabel() {
        NSLayoutConstraint.activate([
            departureTimeLabel.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 20),
            departureTimeLabel.leadingAnchor.constraint(equalTo: topSubview.leadingAnchor, constant: 10),
            departureTimeLabel.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.2)
        ])
        departureTimeLabel.text = departureTime
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
            departurePlaceLabel.leadingAnchor.constraint(equalTo: topCircle.trailingAnchor, constant: 10)
        ])
        departurePlaceLabel.text = departurePlace
        departurePlaceLabel.textColor = .darkGray
        departurePlaceLabel.font = .boldSystemFont(ofSize: 20)
        departurePlaceLabel.numberOfLines = 1
        departurePlaceLabel.clipsToBounds = true
    }
    
    private func setupDepartureMapButton() {
        NSLayoutConstraint.activate([
            departurePlaceMapButton.trailingAnchor.constraint(equalTo: topSubview.trailingAnchor, constant: -10),
            departurePlaceMapButton.topAnchor.constraint(equalTo: departureTimeLabel.centerYAnchor),
            departurePlaceMapButton.heightAnchor.constraint(equalTo: departureTimeLabel.heightAnchor)
        ])
        departurePlaceMapButton.setImage(UIImage(systemName: "chevron"), for: .normal)
        departurePlaceMapButton.tintColor = .systemGray
        departurePlaceMapButton.isHidden = true
        departurePlaceMapButton.imageView?.contentMode = .scaleAspectFit
        departurePlaceMapButton.contentVerticalAlignment = .fill
        departurePlaceMapButton.contentHorizontalAlignment = .fill
        departurePlaceMapButton.backgroundColor = .red
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
            arrivingTimeLabel.topAnchor.constraint(equalTo: topSubview.centerYAnchor, constant: 10),
            arrivingTimeLabel.leadingAnchor.constraint(equalTo: departureTimeLabel.leadingAnchor),
            arrivingTimeLabel.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.2)
        ])
        arrivingTimeLabel.text = arrivingTime
        arrivingTimeLabel.textColor = .darkGray
        arrivingTimeLabel.font = .boldSystemFont(ofSize: 20)
    }
    
    private func setupBottomCircle() {
        NSLayoutConstraint.activate([
            bottomCircle.centerYAnchor.constraint(equalTo: arrivingTimeLabel.centerYAnchor),
            bottomCircle.centerXAnchor.constraint(equalTo: topCircle.centerXAnchor),
            bottomCircle.widthAnchor.constraint(equalTo: topCircle.widthAnchor),
            bottomCircle.heightAnchor.constraint(equalTo: bottomCircle.widthAnchor, multiplier: 1.1)
        ])
        bottomCircle.tintColor = .darkGray
        bottomCircle.contentMode = .scaleToFill

    }
    
    private func setupArrivingPlace() {
        NSLayoutConstraint.activate([
            arrivingPlaceLabel.centerYAnchor.constraint(equalTo: bottomCircle.centerYAnchor),
            arrivingPlaceLabel.leadingAnchor.constraint(equalTo: bottomCircle.trailingAnchor, constant: 10)

        ])
        arrivingPlaceLabel.text = arrivingPlace
        arrivingPlaceLabel.textColor = .darkGray
        arrivingPlaceLabel.font = .boldSystemFont(ofSize: 20)
        arrivingPlaceLabel.numberOfLines = 1
    }
    
    private func setupArrivingMapButton() {
        NSLayoutConstraint.activate([
            arrivingPlaceMapButton.trailingAnchor.constraint(equalTo: topSubview.trailingAnchor, constant: -10),
            arrivingPlaceMapButton.bottomAnchor.constraint(equalTo: arrivingTimeLabel.centerYAnchor),
            arrivingPlaceMapButton.heightAnchor.constraint(equalTo: arrivingTimeLabel.heightAnchor)
        ])
        arrivingPlaceMapButton.setImage(UIImage(systemName: "chevron"), for: .normal)
        arrivingPlaceMapButton.tintColor = .systemGray
        arrivingPlaceMapButton.isHidden = true
        arrivingPlaceMapButton.imageView?.contentMode = .scaleAspectFit
        arrivingPlaceMapButton.contentVerticalAlignment = .fill
        arrivingPlaceMapButton.contentHorizontalAlignment = .fill
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
        passengersCountLabel.text = "Всего за \(passengersCount) пассажира"
        passengersCountLabel.textColor = .systemGray3
        passengersCountLabel.font = .boldSystemFont(ofSize: 15)
    }
    
    private func setupPriceLabel() {
        NSLayoutConstraint.activate([
            priceLabel.centerYAnchor.constraint(equalTo: priceSubview.centerYAnchor),
            priceLabel.trailingAnchor.constraint(equalTo: priceSubview.trailingAnchor, constant: -10),
            priceLabel.heightAnchor.constraint(equalTo: priceSubview.heightAnchor, multiplier: 0.4)
        ])
        priceLabel.text = "\(priceForOne * Float(passengersCount))"
        priceLabel.textColor = .darkGray
        priceLabel.font = . boldSystemFont(ofSize: 20)
    }
}


//MARK:- Helping methods
extension SelectedTripViewController {
    @objc final func goBack() {
        navigationController?.popViewController(animated: true)
    }
}