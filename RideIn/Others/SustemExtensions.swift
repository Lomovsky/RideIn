//
//  Temporary .swift
//  RideIn
//
//  Created by Алекс Ломовской on 12.04.2021.
//

import UIKit

//MARK:- UIColor
extension UIColor {
    static let darkGray = UIColor(red: 0.29, green: 0.30, blue: 0.31, alpha: 1.00)
    static let lightBlue = UIColor(red: 0.01, green: 0.66, blue: 0.95, alpha: 1.00)
}


//MARK:- UIScrollView
//Scrolls paged scrollView
extension UIScrollView {
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

