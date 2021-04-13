//
//  RouterProtocol.swift
//  RideIn
//
//  Created by Алекс Ломовской on 12.04.2021.
//

import UIKit

typealias CompletionBlock = () -> Void

//MARK: PresentableProtocol -
protocol Presentable {
    func toPresent() -> UIViewController?
}


//MARK: RoutableProtocol -
protocol
Routable: Presentable {
    func present(_ module: Presentable?)
    func present(_ module: Presentable?, animated: Bool)
    func present(_ module: Presentable?, animated: Bool, completion: CompletionBlock?)
    
    func presentOverContext(_ module: Presentable?, completion: CompletionBlock?)
    
    func push(_ module: Presentable?)
    func push(_ module: Presentable?, animated: Bool)
    func push(_ module: Presentable?, animated: Bool, completion: CompletionBlock?)
    
    func popModule()
    func popModule(animated: Bool)
    
    func dismissModule()
    func dismissModule(animated: Bool, completion: CompletionBlock?)
    
    func setRootModule(_ module: Presentable?)
    func setRootModule(_ module: Presentable?, hideBar: Bool)
    
    func popToRootModule(animated: Bool)
}


//MARK: UIViewPresentableExtension
extension UIViewController: Presentable {
    func toPresent() -> UIViewController? {
        return self
    }
}



