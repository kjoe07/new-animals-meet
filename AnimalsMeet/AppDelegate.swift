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
import SwiftMessages
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        
        let deviceToken = deviceToken.reduce("", {$0 + String(format: "%02X", $1)})
        print("Device Token: \(deviceToken)")
        App.instance.userData.deviceToken = deviceToken
    }
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        #if OFFLINE
            Api.instance.serverUrl = "http://localhost:3000/v1"
        #elseif DEBUG
            Api.instance.serverUrl = "http://52.169.82.167/v1"//"http://192.168.137.1/v1"//
        #else
            Api.instance.serverUrl = "http://52.169.82.167/v1"
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
                    }else if let notification = launchOptions?[.remoteNotification] as? [String: AnyObject]{
                            let aps = notification["aps"] as! [String: AnyObject]
                            print("remote notification Data: \(aps)")
                            (self.window?.rootViewController as? UITabBarController)?.selectedIndex = 1
                    }else {
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
      //  Fabric.with([Answers.self])
       // Fabric.with([Crashlytics.self])
        UNUserNotificationCenter.current().requestAuthorization(options:[.badge, .alert, .sound], completionHandler: { _,_ in
            application.registerForRemoteNotifications()
        })
        return true
    }
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?,  annotation: Any) -> Bool {
        return FBSDKApplicationDelegate.sharedInstance().application(application, open: url, sourceApplication: sourceApplication, annotation: annotation)
    }
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        let aps = userInfo["aps"] as! [String: AnyObject]
        let custom  = aps["alert"]! as? NSDictionary
        var i = 0
        switch custom?["loc-key"] as! String {
        case "LIKE":
            i = 1
            break
        case "COMMENT":
            i = 3
            break
        case "PROFILE":
            i = 4
            break
        case "BALADE":
            i = 0
            break
        default:
            i = 0
        }
        if application.applicationState == .active {
            
            //let custom = aps["custom_data"] as! [String: AnyObject]
            //alert.showAlertSuccess(title: custom?["title"] as! String + "sent you a Message", subTitle: aps["body"] as! String)
            let view = MessageView.viewFromNib(layout: .CardView)
            view.configureTheme(.success)
            view.configureDropShadow()
            let iconText = ["🐶"].sm_random()!
            view.configureContent(title: custom?["title"] as! String, body: aps["body"] as! String, iconText: iconText)
            view.button?.isHidden = true
            view.tapHandler = {_ in
                /*let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let initialViewController = storyboard.instantiateViewController(withIdentifier: "TabBarVC")
                self.window?.rootViewController = initialViewController
                (self.window?.rootViewController as? UITabBarController)?.selectedIndex = 1

                self.window?.makeKeyAndVisible()*/
                self.presentView(Set: i)
            }
            SwiftMessages.show(view: view)
        }else{
            presentView(Set: i)
        }
    }
    func presentView(Set index: Int){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let initialViewController = storyboard.instantiateViewController(withIdentifier: "TabBarVC")
        self.window?.rootViewController = initialViewController
        (self.window?.rootViewController as? UITabBarController)?.selectedIndex = index
        self.window?.makeKeyAndVisible()
    }
}

