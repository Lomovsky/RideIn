//
//  RecommendedCollectionViewCell.swift
//  RideIn
//
//  Created by Алекс Ломовской on 16.04.2021.
//

import UIKit

class TripCollectionViewCell: UICollectionViewCell {
    
    class var reuseIdentifier: String {
        return "recommendationsCollectionViewCell"
    }
    
    private let backgroundSubview: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let filterTypeSubview: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let filterTypeTopSubview: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let filterTypeLabel: UILabel = {
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
    
    private let arrivingPlaceLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let priceLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    
    //MARK: Initializer-
    override init(frame: CGRect) {
        super.init(frame: .zero)
        contentView.addSubview(backgroundSubview)
        
        setupBackgroundSubview()
        setupFilterTypeSubview()
        setupFilterTypeTopSubview()
        setupFilterTypeLabel()
        setupDepatureTimeLabel()
        setupTopCircle()
        setupDeparturePlace()
        setupLine()
        setupArrivingTimeLabel()
        setupBottomCircle()
        setupArrivingPlace()
        setupPriceLabel()
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: UIMethods -
    private func setupBackgroundSubview() {
        NSLayoutConstraint.activate([
            backgroundSubview.topAnchor.constraint(equalTo: contentView.topAnchor),
            backgroundSubview.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            backgroundSubview.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            backgroundSubview.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
        backgroundSubview.backgroundColor = .white
        backgroundSubview.layer.cornerRadius = 15
        backgroundSubview.addSubview(filterTypeSubview)
        backgroundSubview.addSubview(departureTimeLabel)
        backgroundSubview.addSubview(topCircle)
        backgroundSubview.addSubview(arrivingTimeLabel)
        backgroundSubview.addSubview(bottomCircle)
        backgroundSubview.addSubview(lineView)
        backgroundSubview.addSubview(departurePlaceLabel)
        backgroundSubview.addSubview(arrivingPlaceLabel)
        backgroundSubview.addSubview(priceLabel)
    }
    
    private func setupFilterTypeSubview() {
        NSLayoutConstraint.activate([
            filterTypeSubview.topAnchor.constraint(equalTo: backgroundSubview.topAnchor),
            filterTypeSubview.leadingAnchor.constraint(equalTo: backgroundSubview.leadingAnchor, constant: 20),
            filterTypeSubview.heightAnchor.constraint(equalTo: backgroundSubview.heightAnchor, multiplier: 0.12),
            filterTypeSubview.widthAnchor.constraint(equalTo: backgroundSubview.widthAnchor, multiplier: 0.4)
        ])
        filterTypeSubview.backgroundColor = .lightBlue
        filterTypeSubview.layer.cornerRadius = 10
        filterTypeSubview.addSubview(filterTypeTopSubview)
        filterTypeSubview.addSubview(filterTypeLabel)
    }
    
    private func setupFilterTypeTopSubview() {
        NSLayoutConstraint.activate([
            filterTypeTopSubview.topAnchor.constraint(equalTo: filterTypeSubview.topAnchor),
            filterTypeTopSubview.bottomAnchor.constraint(equalTo: filterTypeSubview.centerYAnchor),
            filterTypeTopSubview.widthAnchor.constraint(equalTo: filterTypeSubview.widthAnchor),
            filterTypeTopSubview.centerXAnchor.constraint(equalTo: filterTypeSubview.centerXAnchor)
        ])
        filterTypeTopSubview.backgroundColor = .lightBlue
    }
    
    private func setupFilterTypeLabel() {
        NSLayoutConstraint.activate([
            filterTypeLabel.centerXAnchor.constraint(equalTo: filterTypeSubview.centerXAnchor),
            filterTypeLabel.centerYAnchor.constraint(equalTo: filterTypeSubview.centerYAnchor)
        ])
        filterTypeLabel.backgroundColor = .lightBlue
        filterTypeLabel.font = .boldSystemFont(ofSize: 15)
        filterTypeLabel.textColor = .white
        filterTypeLabel.text = "Быстрее всего"
        filterTypeLabel.textAlignment = .center
    }
    
    private func setupDepatureTimeLabel() {
        NSLayoutConstraint.activate([
            departureTimeLabel.topAnchor.constraint(equalTo: filterTypeSubview.bottomAnchor, constant: 20),
            departureTimeLabel.leadingAnchor.constraint(equalTo: backgroundSubview.leadingAnchor, constant: 20)
        ])
        departureTimeLabel.text = "22:30"
        departureTimeLabel.textColor = .darkGray
        departureTimeLabel.font = .boldSystemFont(ofSize: 20)
    }
    
    private func setupTopCircle() {
        NSLayoutConstraint.activate([
            topCircle.centerYAnchor.constraint(equalTo: departureTimeLabel.centerYAnchor),
            topCircle.leadingAnchor.constraint(equalTo: departureTimeLabel.trailingAnchor, constant: 20)
        ])
        topCircle.tintColor = .darkGray
        topCircle.contentMode = .scaleToFill
    }
    
    private func setupDeparturePlace() {
        NSLayoutConstraint.activate([
            departurePlaceLabel.centerYAnchor.constraint(equalTo: departureTimeLabel.centerYAnchor),
            departurePlaceLabel.leadingAnchor.constraint(equalTo: topCircle.trailingAnchor, constant: 10),
            departurePlaceLabel.trailingAnchor.constraint(equalTo: priceLabel.leadingAnchor, constant: -5)
        ])
        departurePlaceLabel.text = "Херсон"
        departurePlaceLabel.textColor = .darkGray
        departurePlaceLabel.font = .boldSystemFont(ofSize: 15)
        departurePlaceLabel.numberOfLines = 1
        departurePlaceLabel.clipsToBounds = true
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
            arrivingTimeLabel.topAnchor.constraint(equalTo: backgroundSubview.centerYAnchor),
            arrivingTimeLabel.leadingAnchor.constraint(equalTo: backgroundSubview.leadingAnchor, constant: 20)
        ])
        arrivingTimeLabel.text = "23:40"
        arrivingTimeLabel.textColor = .darkGray
        arrivingTimeLabel.font = .boldSystemFont(ofSize: 20)
    }
    
    private func setupBottomCircle() {
        NSLayoutConstraint.activate([
            bottomCircle.centerYAnchor.constraint(equalTo: arrivingTimeLabel.centerYAnchor),
            bottomCircle.centerXAnchor.constraint(equalTo: topCircle.centerXAnchor)
        ])
        bottomCircle.tintColor = .darkGray
        bottomCircle.contentMode = .scaleToFill

    }
    
    private func setupArrivingPlace() {
        NSLayoutConstraint.activate([
            arrivingPlaceLabel.centerYAnchor.constraint(equalTo: arrivingTimeLabel.centerYAnchor),
            arrivingPlaceLabel.leadingAnchor.constraint(equalTo: bottomCircle.trailingAnchor, constant: 10),
            arrivingPlaceLabel.trailingAnchor.constraint(equalTo: priceLabel.leadingAnchor, constant:  -5)
        ])
        arrivingPlaceLabel.text = "Николаев"
        arrivingPlaceLabel.textColor = .darkGray
        arrivingPlaceLabel.font = .boldSystemFont(ofSize: 15)
        arrivingPlaceLabel.numberOfLines = 1
    }
    
    private func setupPriceLabel() {
        NSLayoutConstraint.activate([
            priceLabel.centerYAnchor.constraint(equalTo: departurePlaceLabel.centerYAnchor),
            priceLabel.trailingAnchor.constraint(equalTo: backgroundSubview.trailingAnchor, constant: -25),
        ])
        priceLabel.text = "150"
        priceLabel.textColor = .darkGray
        priceLabel.font = .boldSystemFont(ofSize: 15)
    }
    
    func configureTheCell(departurePlace: String, arrivingPlace: String, departureTime: String, arrivingTime: String, filterType: String?, price: String) {
        
        priceLabel.text = price
        departurePlaceLabel.text = departurePlace
        arrivingPlaceLabel.text = arrivingPlace
        departureTimeLabel.text = departureTime
        arrivingTimeLabel.text = arrivingTime
        
        if filterType != nil {
            filterTypeLabel.text = filterType
        } else {
            filterTypeLabel.isHidden = true
            filterTypeSubview.isHidden = true
            filterTypeTopSubview.isHidden = true
        }
    }
}
