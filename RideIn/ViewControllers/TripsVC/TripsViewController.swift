//
//  TripsViewController.swift
//  RideIn
//
//  Created by Алекс Ломовской on 15.04.2021.
//

import UIKit


final class TripsViewController: UIViewController {
    
    //MARK: Declarations -
    /// The manager to convent date and time from Trip object to more user-friendly style
    lazy var dateTimeFormatter: DateTimeFormatter = makeDateFormatter()
    
    /// The base unsorted array of available trips
    var trips = [Trip]()
    
    /// The sorted array of available trips with increasing price
    var cheapTripsToTop = [Trip]()
    
    /// The sorted array of available trips with decreasing price
    var cheapTripsToBottom = [Trip]()
    
    /// The cheapest trip
    var cheapestTrip: Trip?
    
    /// The closest to user departure  point trip
    var closestTrip: Trip?
    
    
    /// The name of the departure place
    var departurePlaceName = String()
    
    /// The name of destination place
    var destinationPlaceName = String()
    
    /// Number of passengers
    var numberOfPassengers = Int()
    
    /// The selected trip departure date
    var date = "Сегодня"
        
    weak var rideSearchDelegate: RideSearchDelegate?
    
    //MARK: UIElements -
    let scrollView: UIScrollView = {
        let scroll = UIScrollView()
        scroll.translatesAutoresizingMaskIntoConstraints = false
        return scroll
    }()
    
    let contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
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
    
    let fromLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let arrowImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    let toLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let detailsLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let recommendationsCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let cv = UICollectionView(frame:.init(x: 0, y: 0, width: 0, height: 0), collectionViewLayout: layout)
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.register(TripCollectionViewCell.self,
                    forCellWithReuseIdentifier: TripCollectionViewCell.recommendationsReuseIdentifier)
        return cv
    }()
    
    let pagesSegmentedControl: UISegmentedControl = {
        let control = UISegmentedControl()
        control.translatesAutoresizingMaskIntoConstraints = false
        return control
    }()
    
    let segmentIndicator: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.lightBlue
        return view
    }()
    
    let pageScrollSubview: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let pageScrollView: UIScrollView = {
        let scroll = UIScrollView()
        scroll.translatesAutoresizingMaskIntoConstraints = false
        return scroll
    }()
    
    
    let allTipsCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let cv = UICollectionView(frame: CGRect(), collectionViewLayout: layout)
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.register(TripCollectionViewCell.self, forCellWithReuseIdentifier: TripCollectionViewCell.allTripsReuseIdentifier)
        cv.backgroundColor = .white
        return cv
    }()
    
    let cheapTripsToTopCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let cv = UICollectionView(frame: .init(x: 0, y: 178, width: 0, height: 0), collectionViewLayout: layout)
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.register(TripCollectionViewCell.self, forCellWithReuseIdentifier: TripCollectionViewCell.cheapToTopReuseIdentifier)
        cv.backgroundColor = .green
        return cv
    }()
    
    
    let cheapTripsToBottomCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let cv = UICollectionView(frame: .init(x: 0, y: 0, width: 0, height: 0), collectionViewLayout: layout)
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.register(TripCollectionViewCell.self, forCellWithReuseIdentifier: TripCollectionViewCell.cheapToBottomReuseIdentifier)
        return cv
    }()
    
    
    //MARK: viewDidLoad -
    override func viewDidLoad() {
        super.viewDidLoad()
        recommendationsCollectionView.delegate = self
        recommendationsCollectionView.dataSource = self
        allTipsCollectionView.dataSource = self
        allTipsCollectionView.delegate = self
        cheapTripsToTopCollectionView.dataSource = self
        cheapTripsToTopCollectionView.delegate = self
        cheapTripsToBottomCollectionView.delegate = self
        cheapTripsToBottomCollectionView.dataSource = self
        
        view.addSubview(navigationSubview)
        view.addSubview(contentSubview)
        view.addSubview(recommendationsCollectionView)
        view.addSubview(pagesSegmentedControl)
        view.addSubview(pageScrollSubview)
    
        setupView()
        setupNavigationController()
        setupNavigationSubview()
        setupContentSubview()
        setupBackButton()
        setupFromLabel()
        setupArrowImageView()
        setupToLabel()
        setupDetailsLabel()
        setupRecommendationCollectionView()
        setupPagesSegmentedControl()
        setupPageScrollSubview()
    }
    
    
    override func viewDidLayoutSubviews() {
        setupPageScroll()
        setupAllTripsCollectionView()
        setupCheapToTopCollectionView()
        setupExpensiveToTopCollectionView()
    }
    
    //MARK: UIMethods -
    private func setupView() {
        view.backgroundColor = .white
    }
    
    private func setupNavigationController() {
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    private func setupNavigationSubview() {
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
        contentSubview.addSubview(fromLabel)
        contentSubview.addSubview(arrowImageView)
        contentSubview.addSubview(toLabel)
        contentSubview.addSubview(detailsLabel)
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
        backButton.addTarget(self, action: #selector(backButtonPressed), for: .touchUpInside)
    }
    
    private func setupFromLabel() {
        NSLayoutConstraint.activate([
            fromLabel.topAnchor.constraint(equalTo: contentSubview.topAnchor, constant: 10),
            fromLabel.leadingAnchor.constraint(equalTo: backButton.trailingAnchor),
            fromLabel.trailingAnchor.constraint(equalTo: contentSubview.centerXAnchor, constant: -5)
        ])
        fromLabel.text = departurePlaceName
        fromLabel.textColor = .darkGray
        fromLabel.font = .boldSystemFont(ofSize: 15)
        fromLabel.clipsToBounds = true
    }
    
    private func setupArrowImageView() {
        NSLayoutConstraint.activate([
            arrowImageView.centerXAnchor.constraint(equalTo: contentSubview.centerXAnchor),
            arrowImageView.centerYAnchor.constraint(equalTo: fromLabel.centerYAnchor)
        ])
        arrowImageView.image = UIImage(systemName: "arrow.right")
        arrowImageView.tintColor = .darkGray
    }
    
    private func setupToLabel() {
        NSLayoutConstraint.activate([
            toLabel.centerYAnchor.constraint(equalTo: fromLabel.centerYAnchor),
            toLabel.trailingAnchor.constraint(equalTo: contentSubview.trailingAnchor),
            toLabel.leadingAnchor.constraint(equalTo: arrowImageView.trailingAnchor, constant: 5)
        ])
        toLabel.text = destinationPlaceName
        toLabel.textColor = .darkGray
        toLabel.font = .boldSystemFont(ofSize: 15)
        toLabel.textAlignment = .center
        toLabel.clipsToBounds = true
    }
    
    private func setupDetailsLabel() {
        NSLayoutConstraint.activate([
            detailsLabel.topAnchor.constraint(equalTo: fromLabel.bottomAnchor, constant: 10),
            detailsLabel.leadingAnchor.constraint(equalTo: backButton.trailingAnchor)
        ])
        detailsLabel.text = "\(date.capitalized), \(numberOfPassengers) человек"
        detailsLabel.font = .boldSystemFont(ofSize: 10)
        detailsLabel.textColor = .systemGray
    }
    
    private func setupRecommendationCollectionView() {
        NSLayoutConstraint.activate([
            recommendationsCollectionView.topAnchor.constraint(equalTo: navigationSubview.bottomAnchor, constant: 10),
            recommendationsCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            recommendationsCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            recommendationsCollectionView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.25)
        ])
        recommendationsCollectionView.backgroundColor = .systemGray5
        recommendationsCollectionView.contentInset = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)
        recommendationsCollectionView.showsHorizontalScrollIndicator = false
    }
    
    private func setupPagesSegmentedControl() {
        NSLayoutConstraint.activate([
            pagesSegmentedControl.topAnchor.constraint(equalTo: recommendationsCollectionView.bottomAnchor),
            pagesSegmentedControl.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            pagesSegmentedControl.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            pagesSegmentedControl.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.06)
        ])
        
        pagesSegmentedControl.insertSegment(with: UIImage(systemName: "wallet.pass.fill"), at: 0, animated: false)
        pagesSegmentedControl.insertSegment(with: UIImage(systemName: "arrow.up"), at: 1, animated: false)
        pagesSegmentedControl.insertSegment(with: UIImage(systemName: "arrow.down"), at: 2, animated: false)
        
        pagesSegmentedControl.selectedSegmentIndex = 0
        
        pagesSegmentedControl.setTitleTextAttributes([NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 20), NSAttributedString.Key.foregroundColor: UIColor.darkGray], for: .normal)
        
        pagesSegmentedControl.setTitleTextAttributes([NSAttributedString.Key.font :  UIFont.boldSystemFont(ofSize: 20), NSAttributedString.Key.foregroundColor: UIColor.lightBlue], for: .selected)
        pagesSegmentedControl.addTarget(self, action: #selector(segmentedControlHandler(sender:)), for: .valueChanged)
        
    }
    
    private func setupPageScrollSubview() {
        NSLayoutConstraint.activate([
            pageScrollSubview.topAnchor.constraint(equalTo: pagesSegmentedControl.bottomAnchor),
            pageScrollSubview.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            pageScrollSubview.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            pageScrollSubview.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        pageScrollSubview.backgroundColor = .white
        pageScrollSubview.addSubview(pageScrollView)
        
    }
    
    private func setupPageScroll() {
        NSLayoutConstraint.activate([
            pageScrollView.topAnchor.constraint(equalTo: pageScrollSubview.topAnchor),
            pageScrollView.bottomAnchor.constraint(equalTo: pageScrollSubview.bottomAnchor),
            pageScrollView.leadingAnchor.constraint(equalTo: pageScrollSubview.safeAreaLayoutGuide.leadingAnchor),
            pageScrollView.trailingAnchor.constraint(equalTo: pageScrollSubview.safeAreaLayoutGuide.trailingAnchor)
        ])
        pageScrollView.isPagingEnabled = true
        pageScrollView.contentSize = CGSize(width: pageScrollSubview.frame.width * CGFloat(3), height: pageScrollSubview.frame.height)
        pageScrollView.addSubview(allTipsCollectionView)
        pageScrollView.addSubview(cheapTripsToTopCollectionView)
        pageScrollView.addSubview(cheapTripsToBottomCollectionView)
        pageScrollView.delegate = self
    }
    
    
    private func setupAllTripsCollectionView() {
        allTipsCollectionView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: pageScrollView.frame.height)
        allTipsCollectionView.backgroundColor = .white
        allTipsCollectionView.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
    }
    
    
    private func setupCheapToTopCollectionView() {
        cheapTripsToTopCollectionView.frame = CGRect(x: view.frame.width, y: 0, width: view.frame.width, height: pageScrollView.frame.height)
        cheapTripsToTopCollectionView.backgroundColor = .white
        cheapTripsToTopCollectionView.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
    }
    
    private func setupExpensiveToTopCollectionView() {
        cheapTripsToBottomCollectionView.frame = CGRect(x: view.frame.width * 2, y: 0, width: view.frame.width, height: pageScrollView.frame.height)
        cheapTripsToBottomCollectionView.backgroundColor = .white
        cheapTripsToBottomCollectionView.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
    }
    
    deinit {
        print("deallocating \(self)")
    }
    
}


private extension TripsViewController {
    func makeDateFormatter() -> DateTimeFormatter {
        let dateTimeManager = MainDateTimeFormatter()
        return dateTimeManager
    }
}
