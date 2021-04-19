//
//  Temporary .swift
//  RideIn
//
//  Created by Алекс Ломовской on 12.04.2021.
//

import UIKit

extension UIColor {
    static let darkGray = UIColor(red: 0.29, green: 0.30, blue: 0.31, alpha: 1.00)
    static let lightBlue = UIColor(red: 0.01, green: 0.66, blue: 0.95, alpha: 1.00)
}

extension UICollectionView {
    
    func setPosition(view: UIView) {
        NSLayoutConstraint.activate([
            topAnchor.constraint(equalTo: view.topAnchor),
            leadingAnchor.constraint(equalTo: view.leadingAnchor),
            trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    func equalFrame(view: UIView) {
        NSLayoutConstraint.activate([
            widthAnchor.constraint(equalTo: view.widthAnchor),
            heightAnchor.constraint(equalTo: view.heightAnchor)

        ])
    }
}


