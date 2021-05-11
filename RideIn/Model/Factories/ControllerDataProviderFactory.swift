//
//  ControllerDataProviderFactory.swift
//  RideIn
//
//  Created by Алекс Ломовской on 07.05.2021.
//

import UIKit

protocol ControllerDataProvidersFactory {
    static func makeProvider(for viewController: UIViewController) -> ControllerDataProvidable?
}

//MARK:- MainControllerDataProviderFactory
struct MainControllerDataProviderFactory: ControllerDataProvidersFactory {
    
    static func makeProvider(for viewController: UIViewController) -> ControllerDataProvidable? {
        switch viewController {
        case is RideSearchViewController:
            return RideSearchViewControllerDataProvider(parentController: viewController)
            
        case is MapViewController:
            return MapViewControllerDataProvider(parentController: viewController)
            
        case is SelectedTripViewController:
            return SelectedTripViewControllerDataProvider(parentController: viewController)
            
        default:
            return nil
        }
    }
}
