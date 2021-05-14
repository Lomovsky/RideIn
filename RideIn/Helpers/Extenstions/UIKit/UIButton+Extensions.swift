//
//  UIButton+Extensions.swift
//  RideIn
//
//  Created by Алекс Ломовской on 11.05.2021.
//

import UIKit

extension UIButton {
    static func createDefaultButton() -> UIButton {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }
}
