//
//  MainConstraintFactory.swift
//  RideIn
//
//  Created by Алекс Ломовской on 06.05.2021.
//

import UIKit

//MARK:- ConstraintFactory
struct MainConstraintFactory: ConstraintFactory {
    
    let view: UIView
    
    let destinationContentSubview: UIView
    
    let destinationTextField: UITextField
    
    let tableViewSubview: UIView
    
    func makeConstraint(forAnimationState state: AnimationState, animatingView: AnimatingViews,
                        tableSubviewTopAnchor toView: UIView) -> NSLayoutConstraint {
        switch animatingView {
        case .tableViewSubview:
            switch state {
            case .animated:
                return NSLayoutConstraint(item: tableViewSubview, attribute: .top,
                                          relatedBy: .equal, toItem: toView,
                                          attribute: .bottom, multiplier: 1,
                                          constant: 0)
                
            case .dismissed:
                return NSLayoutConstraint(item: tableViewSubview, attribute: .top,
                                                       relatedBy: .equal, toItem: toView,
                                                       attribute: .centerY, multiplier: 1,
                                                       constant: 0)
            }
            
        case.toContentSubview:
            switch state {
            case .animated:
                return NSLayoutConstraint(item: destinationContentSubview, attribute: .top,
                                          relatedBy: .equal, toItem: view.safeAreaLayoutGuide,
                                          attribute: .top, multiplier: 1,
                                          constant: 30)
                
            case .dismissed:
                return NSLayoutConstraint(item: destinationContentSubview, attribute: .top,
                                          relatedBy: .equal, toItem: view.safeAreaLayoutGuide,
                                          attribute: .top, multiplier: 1,
                                          constant: 45 + (view.frame.height * 0.07))
            }
            
        case.toTextField:
            switch state {
            case .animated:
                return NSLayoutConstraint(item: destinationTextField, attribute: .top,
                                          relatedBy: .equal, toItem: view.safeAreaLayoutGuide,
                                          attribute: .top, multiplier: 1,
                                          constant: 30)
            case.dismissed:
                return NSLayoutConstraint(item: destinationTextField, attribute: .top,
                                          relatedBy: .equal, toItem: view.safeAreaLayoutGuide,
                                          attribute: .top, multiplier: 1,
                                          constant: 45 + (view.frame.height * 0.07))
            }
        }
    }
    
    init(view: UIView, destinationContentSubview: UIView, destinationTextField: UITextField, tableViewSubview: UIView) {
        self.view = view
        self.destinationContentSubview = destinationContentSubview
        self.destinationTextField = destinationTextField
        self.tableViewSubview = tableViewSubview
    }
}
