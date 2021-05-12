//
//  UIScrollViewExtensions.swift
//  RideIn
//
//  Created by Алекс Ломовской on 11.05.2021.
//

import UIKit

extension UIScrollView {
    
    static func createDefaultScrollView() -> UIScrollView {
        let scroll = UIScrollView()
        scroll.translatesAutoresizingMaskIntoConstraints = false
        return scroll
    }
    
    /// This method id responsible for scrolling any paged scrollView to a specific page
    /// - Parameters:
    ///   - horizontalPage: the horizontal page to scroll to
    ///   - verticalPage: the vertical page to scroll to
    ///   - numberOfPages: total number of pages
    ///   - animated: should scroll be rather animated or not
    func scrollTo(horizontalPage: Int? = 0, verticalPage: Int? = 0, numberOfPages: Int? = 0, animated: Bool? = true) {
        let contentWidth = contentSize.width
        let width = contentWidth / CGFloat(numberOfPages ?? 0)
        
        let contentHeight = contentSize.height
        let height = contentHeight / CGFloat(numberOfPages ?? 0)
        
        let xMultiplier = horizontalPage ?? 0 / 100
        let yMultiplier = verticalPage ?? 0 / 100
        
        let position = CGPoint(x: width * CGFloat(xMultiplier), y: height * CGFloat(yMultiplier))
        
        if animated ?? true {
            UIView.animate(withDuration: 0.2) {
                self.contentOffset = position
            }
        } else {
            contentOffset = position
        }
    }
}
