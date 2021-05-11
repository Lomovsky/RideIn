//
//  UIViewExtensions.swift
//  RideIn
//
//  Created by Алекс Ломовской on 11.05.2021.
//

import UIKit

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
    
    static func createDefaultView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isOpaque = false
        return view
    }
}

