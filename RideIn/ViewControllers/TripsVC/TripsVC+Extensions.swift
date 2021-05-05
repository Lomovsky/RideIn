//
//  TripsVC+Extensions.swift
//  RideIn
//
//  Created by Алекс Ломовской on 20.04.2021.
//

import UIKit

//MARK:- HelpingMethods
extension TripsViewController {
    
    /// This method is called then user press back button
    @objc final func backButtonPressed() {
        rideSearchDelegate?.setNavigationControllerHidden(to: false, animated: false)
        onFinish?()
    }
    
    /// This method is responsible for scrolling to selected page
    /// - Parameter sender: UISegmentedControl that called this method
    @objc final func segmentedControlHandler(sender: UISegmentedControl) {
        pageScrollView.scrollTo(horizontalPage: sender.selectedSegmentIndex, numberOfPages: 3, animated: true)
    }
}

//MARK:- ScrollViewDelegate
extension TripsViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        switch scrollView {
        case pageScrollView: pagesSegmentedControl.selectedSegmentIndex = Int(round(scrollView.contentOffset.x / view.frame.width))
            
        default: break
        }
    }
}

