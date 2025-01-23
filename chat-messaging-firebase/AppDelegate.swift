//
//  AppDelegate.swift
//  chat-messaging-firebase
//
//  Created by Avendi Sianipar on 22/01/25.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        AppController.shared.configureFirebase()
        return true
    }

}

