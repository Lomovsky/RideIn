//
//  Temporary .swift
//  RideIn
//
//  Created by Алекс Ломовской on 12.04.2021.
//

import UIKit
import MapKit

//MARK:- UIColor
extension UIColor {
    static let darkGray = UIColor(red: 0.29, green: 0.30, blue: 0.31, alpha: 1.00)
    static let lightBlue = UIColor(red: 0.01, green: 0.66, blue: 0.95, alpha: 1.00)
}

//MARK:- UIScrollView
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

//MARK:- UIView
extension UIView {
    func setBlurBackground() {
        if !UIAccessibility.isReduceTransparencyEnabled {
            self.backgroundColor = .clear
            let blurEffect = UIBlurEffect(style: .light)
            let blurEffectView = UIVisualEffectView(effect: blurEffect)
            blurEffectView.frame = self.bounds
            blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            self.addSubview(blurEffectView)
        } else {
            self.backgroundColor = .black
        }
    }
}

extension UIView {
    static func createDefaultView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isOpaque = false
        return view
    }
}

//MARK:- UIButton
extension UIButton {
    static func createDefaultButton() -> UIButton {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }
}

//MARK:- UITextField
extension UITextField {
    static func createDefaultTF() -> UITextField {
        let tf = UITextField()
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }
}

//MARK:- UIImageView
extension UIImageView {
    static func createDefaultIV(withImage image: UIImage?) -> UIImageView {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = image
        return imageView
    }
}

//MARK:- UILabel
extension UILabel {
    static func createDefaultLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.isOpaque = false
        return label
    }
}

//MARK:- MKMapView
extension MKMapView {
    static func createDefaultMapView() -> MKMapView {
        let mapView = MKMapView()
        mapView.translatesAutoresizingMaskIntoConstraints = false
        return mapView
    }
}

//MARK:- UICollectionViewCell
extension UICollectionViewCell {
    func addShadow(color: UIColor, radius: CGFloat, opacity: Float) {
        self.layer.shadowColor = color.cgColor
        self.layer.shadowRadius = radius
        self.layer.shadowOpacity = opacity
        self.layer.shadowOffset = CGSize.init(width: 2.5, height: 2.5)
        self.layer.masksToBounds = false
        self.layer.shadowPath = UIBezierPath(rect: self.bounds).cgPath
        self.backgroundColor = .clear
    }
}
