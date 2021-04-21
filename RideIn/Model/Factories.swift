//
//  LinkConstructor.swift
//  RideIn
//
//  Created by Алекс Ломовской on 13.04.2021.
//

import UIKit


//MARK:- USLFactory
struct MainURLFactory: URLFactory {
    
    func setCoordinates(coordinates: String, place: PlaceType) {
        
        switch place {
        case .from: Query.fromCoordinates = coordinates
            
        case .to: Query.toCoordinates = coordinates
        }
    }
    
    func setSeats(seats: String) {
        Query.seats = seats
    }
    
    func setDate(date: String) {
        Query.date = date
    }
    
    func makeURL() -> URL? {
        if Query.date != nil {
            let baseLink = "https://public-api.blablacar.com/api/v3/trips?from_coordinate=\(Query.fromCoordinates)&to_coordinate=\(Query.toCoordinates)&locale=\(Query.country)&currency=\(Query.currency)&seats=\(Query.seats)&count=50&start_date_local=\(Query.date!)&key=\(Query.apiKey)"
            
            guard let url = URL(string: baseLink) else { return nil }
            return url
            
        } else {
            let baseLink = "https://public-api.blablacar.com/api/v3/trips?from_coordinate=\(Query.fromCoordinates)&to_coordinate=\(Query.toCoordinates)&locale=\(Query.country)&currency=\(Query.currency)&seats=\(Query.seats)&count=50&key=\(Query.apiKey)"
            
            guard let url = URL(string: baseLink) else { return nil }
            return url
        }
    }
    
}

//MARK:- ConstraintFactory
struct ConstraintFactory: Constraintable {
    let view: UIView
    let toContentSubview: UIView
    let toTextField: UITextField
    let tableViewSubview: UIView
    
    func makeConstraint(forAnimationState state: AnimationState, animatingView: AnimatingViews, tableSubviewTopAnchor toView: UIView) -> NSLayoutConstraint {
        switch animatingView {
        case .tableViewSubview:
            switch state {
            case .animated:
                return NSLayoutConstraint(item: tableViewSubview, attribute: .top,
                                          relatedBy: .equal, toItem: toView,
                                          attribute: .bottom, multiplier: 1,
                                          constant: 0)
                
            case .dismissed: return NSLayoutConstraint()
            }
            
        case.toContentSubview:
            switch state {
            case .animated:
                return NSLayoutConstraint(item: toContentSubview,
                                          attribute: .top,
                                          relatedBy: .equal,
                                          toItem: view.safeAreaLayoutGuide,
                                          attribute: .top,
                                          multiplier: 1,
                                          constant: 30)
                
            case .dismissed:
                return NSLayoutConstraint(item: toContentSubview,
                                          attribute: .top,
                                          relatedBy: .equal,
                                          toItem: view.safeAreaLayoutGuide,
                                          attribute: .top,
                                          multiplier: 1,
                                          constant: 45 + (view.frame.height * 0.07))
            }
            
        case.toTextField:
            switch state {
            case .animated:
                return NSLayoutConstraint(item: toTextField,
                                          attribute: .top,
                                          relatedBy: .equal,
                                          toItem: view.safeAreaLayoutGuide,
                                          attribute: .top,
                                          multiplier: 1,
                                          constant: 30)
            case.dismissed:
                return NSLayoutConstraint(item: toTextField,
                                          attribute: .top,
                                          relatedBy: .equal,
                                          toItem: view.safeAreaLayoutGuide,
                                          attribute: .top,
                                          multiplier: 1,
                                          constant: 45 + (view.frame.height * 0.07))
            }
        }
    }
    
    init(view: UIView, toContentSubview: UIView, toTextField: UITextField, tableViewSubview: UIView) {
        self.view = view
        self.toContentSubview = toContentSubview
        self.toTextField = toTextField
        self.tableViewSubview = tableViewSubview
    }
    
}

