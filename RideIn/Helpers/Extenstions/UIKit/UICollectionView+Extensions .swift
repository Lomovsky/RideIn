//
//  UICollectionView+Extensions .swift
//  RideIn
//
//  Created by Алекс Ломовской on 11.05.2021.
//

import UIKit

//MARK:- UICollectionView
extension UICollectionView {
    func register<T: UICollectionViewCell>(_: T.Type) where T: ReusableView {
        register(T.self, forCellWithReuseIdentifier: T.defaultReuseIdentifier)
    }
    
    func dequeueReusableCell<T: UICollectionViewCell>(for indexPath: IndexPath) -> T where T: ReusableView {
        guard let cell = dequeueReusableCell(withReuseIdentifier: T.defaultReuseIdentifier, for: indexPath) as? T else {
            fatalError("Could not dequeue cell with identifier: \(T.defaultReuseIdentifier)")
        }
        return cell
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
