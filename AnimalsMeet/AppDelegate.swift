//
//  AppDelegate.swift
//  AnimalsMeet
//
//  Created by Sacha IFRAH on 03/10/2016.
//  Copyright © 2016 AnimalsMeet. All rights reserved.
//

import UIKit
import Fabric
import FBSDKShareKit
import FBSDKLoginKit
import FBSDKCoreKit
import UserNotifications
import Crashlytics
import IQKeyboardManagerSwift
import ARSLineProgress

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {
   
   var window: UIWindow?
   
   func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
      
      let deviceToken = deviceToken.reduce("", {$0 + String(format: "%02X", $1)})
      App.instance.userData.deviceToken = deviceToken
   }
   
   func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
      
              Api.instance.serverUrl = "http://api.animals-meet.com/v1"
//      Api.instance.serverUrl = "http://192.168.1.2:3000/v1"
      App.instance.loadUserData()
      
      IQKeyboardManager.sharedManager().enable = true
      
      if App.instance.userData.accessToken != nil {
         
         ARSLineProgress.show()
         
         let storyboard = UIStoryboard(name: "Main", bundle: nil)
         let tabBarViewController = storyboard.instantiateViewController(withIdentifier: "TabBarVC")
         self.window?.rootViewController = tabBarViewController
         self.window?.makeKeyAndVisible()
         App.instance.requestUserBreedsAndAnimals()
            .always {
               ARSLineProgress.hide()
            }.catch { err in
               print(err)
               App.instance.logout()
         }
      }
      
      Fabric.with([Answers.self])
      Fabric.with([Crashlytics.self])
      
      
      UNUserNotificationCenter.current().requestAuthorization(options:[.badge, .alert, .sound], completionHandler: { _,_ in
         application.registerForRemoteNotifications()
      })
      
      return true
   }
   
   func application(_ application: UIApplication, open url: URL, sourceApplication: String?,  annotation: Any) -> Bool {
      
      return FBSDKApplicationDelegate.sharedInstance().application(application,
                                                                   open: url,
                                                                   sourceApplication: sourceApplication,
                                                                   annotation: annotation)
   }
}

