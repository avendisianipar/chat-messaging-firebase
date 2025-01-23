//
//  SceneDelegate.swift
//  chat-messaging-firebase
//
//  Created by Avendi Sianipar on 22/01/25.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else {
            return
        }
        let window = UIWindow(windowScene: windowScene)
        AppController.shared.show(in: window)
    }
}

