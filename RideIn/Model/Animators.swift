//
//  Animators.swift
//  RideIn
//
//  Created by Алекс Ломовской on 13.04.2021.
//

import UIKit

class BaseAnimator: AnimatableControl, AnimatableView {
    func animateControl<Object>(_: Object, _: UINavigationController) where Object : UIControl {}
    func undoControlAnimation<Object>(_: Object, _: UINavigationController) where Object : UIControl {}
    func animateView<Object>(_: Object, _: UINavigationController) where Object : UIView {}
    func undoViewAnimation<Object>(_: Object, _: UINavigationController) where Object : UIView {}
    
}

final class TextFieldAnimator: BaseAnimator {
    
    
    override func animateControl<Object>(_ object: Object, _ navController: UINavigationController) where Object : UIControl {
        guard let textField = object as? UITextField else { return }
        UIView.animate(withDuration: 0.3) {
            navController.setNavigationBarHidden(true, animated: true)
            textField.frame = CGRect(x: textField.frame.origin.x,
                                      y: textField.frame.origin.y - navController.navigationBar.frame.height,
                                      width: textField.frame.width,
                                      height: textField.frame.height)
        }
    }
    
    func animateSecondControl<Object>(_ object: Object, _ navController: UINavigationController) where Object : UIControl {
        guard let textField = object as? UITextField else { return }
        UIView.animate(withDuration: 0.3) {
            navController.setNavigationBarHidden(true, animated: true)
            textField.frame = CGRect(x: textField.frame.origin.x,
                                     y: textField.frame.origin.y - navController.navigationBar.frame.height - 30,
                                      width: textField.frame.width,
                                      height: textField.frame.height)
        }
    }
    
    override func undoControlAnimation<Object>(_ object: Object, _ navController: UINavigationController) where Object : UIControl {
        guard let textField = object as? UITextField else { return }
        UIView.animate(withDuration: 0.3) {
            navController.setNavigationBarHidden(false, animated: true)
            textField.frame = CGRect(x: textField.frame.origin.x,
                                      y: textField.frame.origin.y + navController.navigationBar.frame.height,
                                      width: textField.frame.width,
                                      height: textField.frame.height)
        }
    }
    
    func undoSecondControlAnimation<Object>(_ object: Object, _ navController: UINavigationController) where Object : UIControl {
        guard let textField = object as? UITextField else { return }
        UIView.animate(withDuration: 0.3) {
            navController.setNavigationBarHidden(false, animated: true)
            textField.frame = CGRect(x: textField.frame.origin.x,
                                      y: textField.frame.origin.y + navController.navigationBar.frame.height + 30,
                                      width: textField.frame.width,
                                      height: textField.frame.height)
        }
    }
    
}

final class ViewAnimator: BaseAnimator {
    
    override func animateView<Object>(_ object: Object, _ navController: UINavigationController) where Object : UIView {
        UIView.animate(withDuration: 0.3) {
            navController.setNavigationBarHidden(true, animated: true)
            object.alpha = 1.0
            object.frame = CGRect(x: object.frame.origin.x,
                                  y: object.frame.origin.y - navController.navigationBar.frame.height,
                                  width: object.frame.width,
                                  height: object.frame.height)
        }
    }
    
    override func undoViewAnimation<Object>(_ object: Object, _ navController: UINavigationController) where Object : UIView {
        UIView.animate(withDuration: 0.3) {
            navController.setNavigationBarHidden(false, animated: true)
            object.alpha = 0.0
            object.frame = CGRect(x: object.frame.origin.x,
                                  y: object.frame.origin.y + navController.navigationBar.frame.height,
                                  width: object.frame.width,
                                  height: object.frame.height)
        }
    }
}

