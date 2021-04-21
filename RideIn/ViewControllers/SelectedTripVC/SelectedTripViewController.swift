//
//  SelectedTripViewController.swift
//  RideIn
//
//  Created by Алекс Ломовской on 21.04.2021.
//

import UIKit

final class SelectedTripViewController: UIViewController {
    
    private let scrollView: UIScrollView = {
        let scroll = UIScrollView()
        scroll.translatesAutoresizingMaskIntoConstraints = false
        return scroll
    }()
    
    private let scrollSubview: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let topSubview: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let button: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
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
    

    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
        setupNavigationController()
    }
    
    private func setupView() {
        view.backgroundColor = .systemGray4
    }
    
    private func setupNavigationController() {
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
   
}
