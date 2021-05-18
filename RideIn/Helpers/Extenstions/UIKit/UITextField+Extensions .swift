//
//  UITextField+Extensions .swift
//  RideIn
//
//  Created by Алекс Ломовской on 11.05.2021.
//

import UIKit

extension UITextField {
  static func createDefaultTF() -> UITextField {
    let tf = UITextField()
    tf.translatesAutoresizingMaskIntoConstraints = false
    return tf
  }
}
