//
//  TripsViewController.swift
//  RideIn
//
//  Created by Алекс Ломовской on 15.04.2021.
//

import UIKit


final class TripsViewController: UIViewController {
    
    var trips = [Trip]()
    var fromPlaceName = "Херсон"
    var toPlaceName = "Николаев"
    var numberOfPassengers = "1 пассажир"
    var date = "Сегодня"
    
    var cheapestTrip: Trip?
    var closestTrip: Trip?
    
    var selectedPage: CGFloat = 0.0
    
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
                    forCellWithReuseIdentifier: TripCollectionViewCell.reuseIdentifier)
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
        cv.register(TripCollectionViewCell.self, forCellWithReuseIdentifier: TripCollectionViewCell.reuseIdentifier)
        cv.backgroundColor = .white
        return cv
    }()
    
    let carTipsCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let cv = UICollectionView(frame: .init(x: 0, y: 178, width: 0, height: 0), collectionViewLayout: layout)
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.register(TripCollectionViewCell.self, forCellWithReuseIdentifier: TripCollectionViewCell.reuseIdentifier)
        cv.backgroundColor = .green
        return cv
    }()
    
    
    let busTripsCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let cv = UICollectionView(frame: .init(x: 0, y: 0, width: 0, height: 0), collectionViewLayout: layout)
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.register(TripCollectionViewCell.self, forCellWithReuseIdentifier: TripCollectionViewCell.reuseIdentifier)
        return cv
    }()
    
    
    //MARK: viewDidLoad -
    override func viewDidLoad() {
        super.viewDidLoad()
        recommendationsCollectionView.delegate = self
        recommendationsCollectionView.dataSource = self
        allTipsCollectionView.dataSource = self
        allTipsCollectionView.delegate = self
        carTipsCollectionView.dataSource = self
        carTipsCollectionView.delegate = self
        busTripsCollectionView.delegate = self
        busTripsCollectionView.dataSource = self
        
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
        setupCarTripsCollectionView()
        setupBusTripsCollectionView()
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
        backButton.addTarget(self, action: #selector(goBack), for: .touchUpInside)
    }
    
    private func setupFromLabel() {
        NSLayoutConstraint.activate([
            fromLabel.topAnchor.constraint(equalTo: contentSubview.topAnchor, constant: 10),
            fromLabel.leadingAnchor.constraint(equalTo: backButton.trailingAnchor),
            fromLabel.trailingAnchor.constraint(equalTo: contentSubview.centerXAnchor, constant: -5)
        ])
        fromLabel.text = fromPlaceName
        fromLabel.textColor = .darkGray
        fromLabel.font = .boldSystemFont(ofSize: 15)
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
        toLabel.text = toPlaceName
        toLabel.textColor = .darkGray
        toLabel.font = .boldSystemFont(ofSize: 15)
        toLabel.textAlignment = .center
    }
    
    private func setupDetailsLabel() {
        NSLayoutConstraint.activate([
            detailsLabel.topAnchor.constraint(equalTo: fromLabel.bottomAnchor, constant: 10),
            detailsLabel.leadingAnchor.constraint(equalTo: backButton.trailingAnchor)
        ])
        detailsLabel.text = "\(date.capitalized), \(numberOfPassengers)"
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
        pagesSegmentedControl.insertSegment(with: UIImage(systemName: "car.fill"), at: 1, animated: false)
        pagesSegmentedControl.insertSegment(with: UIImage(systemName: "bus.fill"), at: 2, animated: false)
        
        pagesSegmentedControl.selectedSegmentIndex = 0
        
        pagesSegmentedControl.setTitleTextAttributes([NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 20), NSAttributedString.Key.foregroundColor: UIColor.darkGray], for: .normal)
        
        pagesSegmentedControl.setTitleTextAttributes([NSAttributedString.Key.font :  UIFont.boldSystemFont(ofSize: 20), NSAttributedString.Key.foregroundColor: UIColor.lightBlue], for: .selected)
        
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
        pageScrollView.addSubview(carTipsCollectionView)
        pageScrollView.addSubview(busTripsCollectionView)
        pageScrollView.delegate = self
    }
    
    
    private func setupAllTripsCollectionView() {
        allTipsCollectionView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: pageScrollView.frame.height)
        allTipsCollectionView.backgroundColor = .white
        allTipsCollectionView.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
    }
    
    
    private func setupCarTripsCollectionView() {
        carTipsCollectionView.frame = CGRect(x: view.frame.width, y: 0, width: view.frame.width, height: pageScrollView.frame.height)
        carTipsCollectionView.backgroundColor = .white
        carTipsCollectionView.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
    }
    
    private func setupBusTripsCollectionView() {
        busTripsCollectionView.frame = CGRect(x: view.frame.width * 2, y: 0, width: view.frame.width, height: pageScrollView.frame.height)
        busTripsCollectionView.backgroundColor = .white
        busTripsCollectionView.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
    }
    
}




//MARK:- HelpingMethods
extension TripsViewController {
    
    @objc func goBack() {
        rideSearchDelegate?.setNavigationControllerHidden(to: false, animated: false)
        navigationController?.popViewController(animated: true)
    }
    
    func lookForCheapestTrip() {
        
    }
    
    func lookForClosestTrip() {
        
    }
}

//MARK:- CollectionViewDataSourse & Delegate
extension TripsViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch collectionView {
        case recommendationsCollectionView: return 2
        case allTipsCollectionView: return 5
        case carTipsCollectionView: return 3
        case busTripsCollectionView: return 4
        default: return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TripCollectionViewCell.reuseIdentifier,
                                                      for: indexPath) as! TripCollectionViewCell
        
        switch collectionView {
        case recommendationsCollectionView:
            cell.layer.shadowColor = UIColor.black.cgColor
            cell.layer.shadowRadius = 4
            cell.layer.shadowOpacity = 0.1
            cell.layer.shadowOffset = CGSize.init(width: 2.5, height: 2.5)
            cell.layer.masksToBounds = false
            cell.layer.shadowPath = UIBezierPath(rect: cell.bounds).cgPath
            cell.backgroundColor = .clear
            
        case allTipsCollectionView:
            cell.layer.shadowColor = UIColor.black.cgColor
            cell.layer.shadowRadius = 5
            cell.layer.shadowOpacity = 0.4
            cell.layer.shadowOffset = CGSize.init(width: 2.5, height: 2.5)
            cell.layer.masksToBounds = false
            cell.layer.shadowPath = UIBezierPath(rect: cell.bounds).cgPath
            cell.backgroundColor = .clear
            
        case carTipsCollectionView:
            cell.layer.shadowColor = UIColor.black.cgColor
            cell.layer.shadowRadius = 5
            cell.layer.shadowOpacity = 0.4
            cell.layer.shadowOffset = CGSize.init(width: 2.5, height: 2.5)
            cell.layer.masksToBounds = false
            cell.layer.shadowPath = UIBezierPath(rect: cell.bounds).cgPath
            cell.backgroundColor = .clear
            
        case busTripsCollectionView:
            cell.layer.shadowColor = UIColor.black.cgColor
            cell.layer.shadowRadius = 5
            cell.layer.shadowOpacity = 0.4
            cell.layer.shadowOffset = CGSize.init(width: 2.5, height: 2.5)
            cell.layer.masksToBounds = false
            cell.layer.shadowPath = UIBezierPath(rect: cell.bounds).cgPath
            cell.backgroundColor = .clear
            
        default:
            break
            
        }
        return cell
    }
    
    
    
}

extension TripsViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let height = collectionView.frame.size.height * 0.9
        let width = collectionView.frame.size.width * 0.8
        
        let pageViewHeight = pageScrollSubview.frame.size.height * 0.4
        let pageViewWidth = pageScrollView.frame.size.width * 0.9
        
        switch collectionView {
        case recommendationsCollectionView: return CGSize(width: width, height: height)
            
        case allTipsCollectionView: return CGSize(width: pageViewWidth, height: pageViewHeight)
            
        case carTipsCollectionView: return CGSize(width: pageViewWidth, height: pageViewHeight)
            
        case busTripsCollectionView: return CGSize(width: pageViewWidth, height: pageViewHeight)
            
        default: return CGSize()
        }
    }
}


extension TripsViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        switch scrollView {
        case pageScrollView:
            let pageIndex = round(scrollView.contentOffset.x / view.frame.width)
            
            switch pageIndex {
            case 0.0:
                allTipsCollectionView.reloadData()
                selectedPage = pageIndex
                pagesSegmentedControl.selectedSegmentIndex = Int(pageIndex)
                
            case 1.0:
                carTipsCollectionView.reloadData()
                print(carTipsCollectionView.numberOfItems(inSection: 0))
                selectedPage = pageIndex
                pagesSegmentedControl.selectedSegmentIndex = Int(pageIndex)
                
            case 2.0:
                busTripsCollectionView.reloadData()
                selectedPage = pageIndex
                pagesSegmentedControl.selectedSegmentIndex = Int(pageIndex)
                
            default: break
            }
            
        default: break
        }
    }
}


