//
//  Animations.swift
//  RideIn
//
//  Created by Алекс Ломовской on 18.05.2021.
//

import Foundation

/// Animation type
enum AnimationState {
  case animated
  case dismissed
}

/// Views to be animated
enum AnimatingViews {
  case toContentSubview
  case toTextField
  case tableViewSubview
}
