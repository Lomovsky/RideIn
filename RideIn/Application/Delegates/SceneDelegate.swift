//
//  SceneDelegate.swift
//  RideIn
//
//  Created by Алекс Ломовской on 12.04.2021.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
  
  var window: UIWindow?
  
  var coordinatorFactory: CoordinatorFactory! {
    didSet {
      coordinator = coordinatorFactory.makeApplicationCoordinator()
      guard let options = coordinatorFactory.deepLinkOptions else { coordinator.start(); return }
      coordinator.start(with: options)
    }
  }
  
  private var coordinator: Coordinatable!
  
  func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
    guard let winScene = (scene as? UIWindowScene) else { return }
    let navController = UINavigationController()
    let win = UIWindow(windowScene: winScene)
    coordinatorFactory = CoordinatorFactoryImp(navigationController: navController)
    window = win
    
  }
  
  func sceneDidDisconnect(_ scene: UIScene) {
    // Called as the scene is being released by the system.
    // This occurs shortly after the scene enters the background, or when its session is discarded.
    // Release any resources associated with this scene that can be re-created the next time the scene connects.
    // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
  }
  
  func sceneDidBecomeActive(_ scene: UIScene) {
    UIApplication.shared.applicationIconBadgeNumber = 0
  }
  
  func sceneWillResignActive(_ scene: UIScene) {
    // Called when the scene will move from an active state to an inactive state.
    // This may occur due to temporary interruptions (ex. an incoming phone call).
  }
  
  func sceneWillEnterForeground(_ scene: UIScene) {
    // Called as the scene transitions from the background to the foreground.
    // Use this method to undo the changes made on entering the background.
  }
  
  func sceneDidEnterBackground(_ scene: UIScene) {
    // Called as the scene transitions from the foreground to the background.
    // Use this method to save data, release shared resources, and store enough scene-specific state information
    // to restore the scene back to its current state.
  }
  
  
}

