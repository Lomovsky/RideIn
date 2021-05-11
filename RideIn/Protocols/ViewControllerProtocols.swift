//
//  ViewControllerProtocols.swift
//  RideIn
//
//  Created by Алекс Ломовской on 13.04.2021.
//

import UIKit

/// This protocol ensures that the class that confirms to this protocol will always have parent viewController
protocol ControllerDataProvidable: AnyObject {
    var parentController: UIViewController? { get set }
}


/// The protocol ensures that the ViewController that confirms to this protocol can be configured by a generics object
protocol ControllerConfigurable {
    associatedtype Object
    func configure(with object: Object)
}

