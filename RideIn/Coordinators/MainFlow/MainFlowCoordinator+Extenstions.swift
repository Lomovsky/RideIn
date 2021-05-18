//
//  MainFlowCoordinator+Extenstions.swift
//  RideIn
//
//  Created by Алекс Ломовской on 14.05.2021.
//

import UIKit

extension MainFlowCoordinator: Alertable {
  
  func makeLocationAlert(title: String?, message: String?, style: UIAlertController.Style) {
    guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else { return }
    guard UIApplication.shared.canOpenURL(settingsUrl) else { return }
    let alert = UIAlertController(title: title, message: message, preferredStyle: style)
    
    let goToSettingsButton = UIAlertAction(title: NSLocalizedString(.Localization.Alert.openSettings, comment: ""),
                                           style: .default) { _ in
      UIApplication.shared.open(settingsUrl)
    }
    
    let dismissButton = UIAlertAction(title: NSLocalizedString(.Localization.Alert.dismiss, comment: ""),
                                      style: .cancel) { [unowned self] _ in
      self.router.popModule()
    }
    
    alert.addAction(dismissButton)
    alert.addAction(goToSettingsButton)
    router.present(alert, animated: true)
  }
  
  func makeAlert(title: String?, message: String?, style: UIAlertController.Style) {
    let alert = UIAlertController(title: title, message: message, preferredStyle: style)
    
    let dismissButton = UIAlertAction(title: NSLocalizedString(.Localization.Alert.dismiss, comment: ""),
                                      style: .cancel) { [unowned self] _ in
      self.router.popModule()
    }
    
    alert.addAction(dismissButton)
    router.present(alert, animated: true)
  }
}
