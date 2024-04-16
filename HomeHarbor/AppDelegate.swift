//
//  AppDelegate.swift
//  HomeHarbor
//
//  Created by Amulya Gangam on 1/22/24.
//

import UIKit
import GoogleSignIn
import CoreData

class AppDelegate: UIResponder, UIApplicationDelegate {
    static let shared = AppDelegate()
    static let signInConfig = GIDConfiguration(clientID: "434565834447-g5ch48mda4nolr24ng2itbm3ahfraath")
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        GIDSignIn.sharedInstance.configuration = AppDelegate.signInConfig
        return true
    }
    
    func application(_ application: UIApplication,open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        let googleDidHandle = GIDSignIn.sharedInstance.handle(url)
        return googleDidHandle
    }
}

