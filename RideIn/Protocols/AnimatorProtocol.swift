//
//  AnimatorProtocol.swift
//  RideIn
//
//  Created by Алекс Ломовской on 13.04.2021.
//

import UIKit


protocol AnimatableControl {
    func animateControl<Object: UIControl>(_:Object, _: UINavigationController)
    func undoControlAnimation<Object: UIControl>(_:Object, _: UINavigationController)
}

protocol AnimatableView {
    func animateView<Object: UIView>(_:Object, _: UINavigationController)
    func undoViewAnimation<Object: UIView>(_:Object, _: UINavigationController)

}

