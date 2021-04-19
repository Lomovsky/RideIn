//
//  TripsViewController.swift
//  RideIn
//
//  Created by Алекс Ломовской on 15.04.2021.
//

import UIKit

class TripsViewController: UIViewController {

    var trips = [Trip]()
    var fromPlaceName = "Херсон"
    var toPlaceName = "Николаев"
    var numberOfPassengers = "1 пассажир"
    var date = "Сегодня"
    
    var cheapestTrip: Trip?
    var closestTrip: Trip?
    
    lazy var views = [allTripsView, carTripsView, busTripsView]
    lazy var collectionViews = [allTipsCollectionView, carTipsCollectionView, busTipsCollectionView]
    
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
        let cv = UICollectionView(frame: CGRect.init(x: 0, y: 0, width: 0, height: 0), collectionViewLayout: layout)
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.register(TripCollectionViewCell.self,
                    forCellWithReuseIdentifier: TripCollectionViewCell.reuseIdentifier)
        return cv
    }()

    let allTripsView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .blue
        return view
    }()
    
    lazy var allTipsCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let cv = UICollectionView(frame: allTripsView.frame, collectionViewLayout: layout)
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.register(TripCollectionViewCell.self, forCellWithReuseIdentifier: TripCollectionViewCell.reuseIdentifier)
        cv.backgroundColor = .white
        return cv
    }()
    
    lazy var carTripsView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var carTipsCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let cv = UICollectionView(frame: carTripsView.frame, collectionViewLayout: layout)
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.register(TripCollectionViewCell.self, forCellWithReuseIdentifier: TripCollectionViewCell.reuseIdentifier)
        cv.backgroundColor = .green
        return cv
    }()
    
    lazy var busTripsView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var busTipsCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let cv = UICollectionView(frame: busTripsView.frame, collectionViewLayout: layout)
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.register(TripCollectionViewCell.self, forCellWithReuseIdentifier: TripCollectionViewCell.reuseIdentifier)
        cv.backgroundColor = .white
        return cv
    }()
    
    lazy var pageScrollSubview: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var pageScrollView: UIScrollView = {
        let scroll = UIScrollView()
        scroll.translatesAutoresizingMaskIntoConstraints = false
        return scroll
    }()
    
    

    
    //MARK: viewDidLoad -
    override func viewDidLoad() {
        super.viewDidLoad()
        recommendationsCollectionView.delegate = self
        recommendationsCollectionView.dataSource = self
//        allTipsCollectionView.delegate = self
//        carTipsCollectionView.delegate = self
//        busTipsCollectionView.delegate = self
        
        view.addSubview(navigationSubview)
        view.addSubview(contentSubview)
//        view.addSubview(scrollView)
        view.addSubview(recommendationsCollectionView)
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
//        setupScrollView()
//        setupContentView()
        setupRecomendationCollectionView()
        setupPageScrollSubview()

    }
    

    
    override func viewDidLayoutSubviews() {
        setupPageScroll()
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
    
//    private func setupScrollView() {
//        scrollView.topAnchor.constraint(equalTo: navigationSubview.bottomAnchor).isActive = true
//        scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
//        scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
//        scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
//        scrollView.addSubview(contentView)
//    }
//
//    private func setupContentView() {
//        contentView.topAnchor.constraint(equalTo: scrollView.topAnchor).isActive = true
//        contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor).isActive = true
//        contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor).isActive = true
//        contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor).isActive = true
//        contentView.widthAnchor.constraint(equalTo: scrollView.safeAreaLayoutGuide.widthAnchor).isActive = true
//        let heightConstraint = contentView.heightAnchor.constraint(equalTo: scrollView.safeAreaLayoutGuide.heightAnchor)
//        heightConstraint.priority = UILayoutPriority(rawValue: 250)
//        heightConstraint.isActive = true
//        contentView.addSubview(recommendationsCollectionView)
//        contentView.addSubview(pageScrollView)
//    }
    
    private func setupRecomendationCollectionView() {
        NSLayoutConstraint.activate([
            recommendationsCollectionView.topAnchor.constraint(equalTo: navigationSubview.bottomAnchor, constant: 10),
            recommendationsCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            recommendationsCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            recommendationsCollectionView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.3)
        ])
        recommendationsCollectionView.backgroundColor = .systemGray5
        recommendationsCollectionView.contentInset = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)
        recommendationsCollectionView.showsHorizontalScrollIndicator = false
    }
    
    private func setupPageScrollSubview() {
        NSLayoutConstraint.activate([
            pageScrollSubview.topAnchor.constraint(equalTo: recommendationsCollectionView.bottomAnchor),
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
        pageScrollView.showsHorizontalScrollIndicator = false
        
        pageScrollView.contentSize = CGSize(width: view.frame.width * CGFloat(views.count), height: pageScrollSubview.frame.height)
        
        for i in 0..<views.count {
            pageScrollView.addSubview(views[i])
            views[i].frame = CGRect(x: view.frame.width * CGFloat(i), y: pageScrollView.frame.origin.y, width: view.frame.width, height: pageScrollView.frame.height)

            views[i].addSubview(collectionViews[i])
            collectionViews[i].delegate = self
            collectionViews[i].dataSource = self

            collectionViews[i].frame = views[i].frame
            collectionViews[i].contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)


        }


        
        pageScrollView.delegate = self
    }
    

    //    private func setupContentView() {
    //        contentView.topAnchor.constraint(equalTo: scrollView.topAnchor).isActive = true
    //        contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor).isActive = true
    //        contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor).isActive = true
    //        contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor).isActive = true
    //        contentView.widthAnchor.constraint(equalTo: scrollView.safeAreaLayoutGuide.widthAnchor).isActive = true
    //        let heightConstraint = contentView.heightAnchor.constraint(equalTo: scrollView.safeAreaLayoutGuide.heightAnchor)
    //        heightConstraint.priority = UILayoutPriority(rawValue: 250)
    //        heightConstraint.isActive = true
    //        contentView.addSubview(recommendationsCollectionView)
    //        contentView.addSubview(pageScrollView)
    //    }
        
    
//    lazy var pageScrollView: UIScrollView = {
//        let height = view.frame.height * 0.552
//        let scroll = UIScrollView()
//        scroll.showsHorizontalScrollIndicator = false
//        scroll.isPagingEnabled = true
//        scroll.translatesAutoresizingMaskIntoConstraints = false
//        scroll.contentSize = CGSize(width: view.frame.width * CGFloat(views.count), height: height)
//
//        for i in 0..<views.count {
//            scroll.addSubview(views[i])
////            views[i].frame = CGRect(x: view.frame.width * CGFloat(i), y: scroll.frame.origin.y, width: view.frame.width, height: height)
//
//            let heightConstraint = views[i].heightAnchor.constraint(equalTo: scroll.safeAreaLayoutGuide.heightAnchor)
//            heightConstraint.priority = UILayoutPriority(rawValue: 250)
//
//            views[i].frame.origin.x = view.frame.width * CGFloat(i)
//            views[i].frame.origin.y = scroll.frame.origin.y
//            views[i].frame.size.width = view.frame.width
//            NSLayoutConstraint.activate([
//                views[i].topAnchor.constraint(equalTo: scroll.topAnchor),
//                views[i].leadingAnchor.constraint(equalTo: scroll.leadingAnchor),
//                views[i].trailingAnchor.constraint(equalTo: scroll.trailingAnchor),
//                views[i].bottomAnchor.constraint(equalTo: scroll.bottomAnchor),
//                heightConstraint
//            ])
//        }
//        scroll.delegate = self
//        view.layoutIfNeeded()
//        return scroll
//    }()
    

    

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
        case busTipsCollectionView: return 4
        default: return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TripCollectionViewCell.reuseIdentifier,
                                                      for: indexPath) as! TripCollectionViewCell
        cell.layer.shadowColor = UIColor.black.cgColor
        cell.layer.shadowRadius = 4
        cell.layer.shadowOpacity = 0.1
        cell.layer.shadowOffset = CGSize.init(width: 2.5, height: 2.5)
        cell.layer.masksToBounds = false
        cell.layer.shadowPath = UIBezierPath(rect: cell.bounds).cgPath
        cell.backgroundColor = .clear
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
            
        case busTipsCollectionView: return CGSize(width: pageViewWidth, height: pageViewHeight)
            
        default: return CGSize()
        }
    }
}


extension TripsViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let pageIndex = round(scrollView.contentOffset.x / view.frame.width)
        
        switch pageIndex {
        case 0.0:
            allTipsCollectionView.reloadData()
            
        case 1.0:
            carTipsCollectionView.reloadData()
            print(carTipsCollectionView.numberOfItems(inSection: 0))
            
        case 2.0:
            busTipsCollectionView.reloadData()
            
        default: break
        }
    }
}
