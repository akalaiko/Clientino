//
//  AppDelegate.swift
//  DropboxClientino
//
//  Created by Tim on 03.09.2023.
//

import SwiftyDropbox
import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        DropboxClientsManager.setupWithAppKey(Constants.appKey)
        return true
    }
}

