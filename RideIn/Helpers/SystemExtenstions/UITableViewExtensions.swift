//
//  UITableViewExtensions.swift
//  RideIn
//
//  Created by Алекс Ломовской on 11.05.2021.
//

import UIKit

//MARK:- UITableView
extension UITableView {
    public func dequeue<Object: UITableViewCell>(cellClass: Object.Type) -> Object? {
        return dequeueReusableCell(withIdentifier: cellClass.reuseIdentifier) as? Object
    }
    
    public func dequeue<Object: UITableViewCell>(cellClass: Object.Type, forIndexPath indexPath: IndexPath) -> Object {
        guard let cell = dequeueReusableCell(
                withIdentifier: cellClass.reuseIdentifier, for: indexPath) as? Object else {
            fatalError(
                "Error: cell with id: \(cellClass.reuseIdentifier) for indexPath: \(indexPath) is not \(Object.self)")
        }
        return cell
    }
}

//MARK:- UICollectionViewCell
extension UITableViewCell {
    static var reuseIdentifier: String {
        return NSStringFromClass(self)
    }
}
