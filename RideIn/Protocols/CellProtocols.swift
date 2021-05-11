//
//  CellProtocols.swift
//  RideIn
//
//  Created by Алекс Ломовской on 11.05.2021.
//

import UIKit

/// This protocol ensures that any class that confirms to this protocol could be updated with either one, two  or none objects
protocol DetailedCellModel {
    associatedtype T
    func update(with object1: T?, object2: T?)
}

/// This protocol is made for simplifying reusing any cells
protocol ReusableView: AnyObject {
    static var defaultReuseIdentifier: String { get }
}

extension ReusableView where Self: UIView {
    static var defaultReuseIdentifier: String {
        return NSStringFromClass(self)
    }
}
