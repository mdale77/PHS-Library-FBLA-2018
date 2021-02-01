//
//  AppDelegate.swift
//  PHS Library
//
//  Created by Mason Dale on 3/5/18.
//  Copyright © 2018 Mason Dale. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    //variables
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        FirebaseApp.configure()
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let loginVC = storyboard.instantiateViewController(withIdentifier: "LoginVC") as! LoginViewController
        self.window?.rootViewController = loginVC
        
        return true
    }

}

