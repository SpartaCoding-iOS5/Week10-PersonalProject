//
//  AppDelegate.swift
//  Pokedex
//
//  Created by Jamong on 1/2/25.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        let window = UIWindow(frame: UIScreen.main.bounds)
        
        window.rootViewController = UINavigationController(rootViewController: ViewController())
        
        window.makeKeyAndVisible()
        
        self.window = window
        
        return true
    }
}

