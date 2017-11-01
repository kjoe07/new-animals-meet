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
        
        #if OFFLINE
            Api.instance.serverUrl = "http://localhost:3000/v1"
        #elseif DEBUG
            Api.instance.serverUrl = "http://52.169.82.167"
        #else
            Api.instance.serverUrl = "http://52.169.82.167"
        #endif
        App.instance.loadUserData()
        
        IQKeyboardManager.sharedManager().enable = true
        
        if App.instance.userData.accessToken != nil {
            
            ARSLineProgress.show()
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let initialViewController = storyboard.instantiateViewController(withIdentifier: "TabBarVC")
            self.window?.rootViewController = initialViewController
            self.window?.makeKeyAndVisible()
            
            App.instance.requestUserBreedsAndAnimals()
                .always {
                    ARSLineProgress.hide()
                }
                .then { () -> Void in
                    // FIXME: put this code in only one place. It's also repeated
                    // in the login controller
                    if App.instance.userModel?.animals?.isEmpty == false {
                        print("Already setup welcome controller")
                        self.window?.rootViewController = initialViewController
                    }
                    else {
                        print("Should display welcome controller")
                        let controller = EditProfileViewController.newInstance()
                        controller.title = "Enregister le profil"
                        
                        controller.onSuccess = {
                            let animalConfigVC = AnimalConfigurationViewController.newInstance()
                            
                            animalConfigVC.onSuccess = {
                                self.window?.rootViewController = initialViewController
                            }
                            
                            controller.navigationController?.pushViewController(animalConfigVC, animated: true)
                        }
                        
                        let navigation = UINavigationController(rootViewController: controller)
                        self.window?.rootViewController = navigation
                    }
                    
                }
                .catch { err in
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

