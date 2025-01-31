//
//  AppController.swift
//  chat-messaging-firebase
//
//  Created by Avendi Sianipar on 23/01/25.
//

import UIKit
import Firebase
import FirebaseAuth

final class AppController {
    
    static let shared = AppController()
    
    private var window: UIWindow!
    
    private var rootViewController: UIViewController? {
        didSet {
            window.rootViewController = rootViewController
        }
    }
    
    init() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleAppState),
            name: .AuthStateDidChange,
            object: nil
        )
    }
    
    // MARK: - Helpers
    func configureFirebase() {
        FirebaseApp.configure()
    }
    
    func show(in window: UIWindow?) {
        guard let window = window else {
            fatalError("Cannot layout app with a nil window.")
        }
        
        self.window = window
        window.tintColor = .base
        window.backgroundColor = .white
        
        handleAppState()
        
        window.makeKeyAndVisible()
    }
    
    // MARK: - Notifications
    @objc private func handleAppState() {
        rootViewController = LoginViewController()
        if let user = Auth.auth().currentUser {
            let channelsViewController = ChannelsViewController(currentUser: user)
            rootViewController = NavigationController(channelsViewController)
        } else {
            rootViewController = LoginViewController()
        }
    }
}
