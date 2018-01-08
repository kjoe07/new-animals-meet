//
//  AppDelegate.swift
//  AnimalsMeet
//
//  Created by Sacha Yoel Jimenez del Valle
//  Copyright © 2017 AnimalsMeet. All rights reserved.
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
	var postID: Int?
	func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
		
		let deviceToken = deviceToken.reduce("", {$0 + String(format: "%02X", $1)})
		print("Device Token: \(deviceToken)")
		App.instance.userData.deviceToken = deviceToken
	}
	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
		#if OFFLINE
			Api.instance.serverUrl = "http://192.168.137.1/v1"
		#elseif DEBUG
			Api.instance.serverUrl = "http://52.169.82.167/v1"//""http://192.168.137.1/v1"//
		#else
			Api.instance.serverUrl = "http://52.169.82.167/v1"
		#endif
		App.instance.loadUserData()
		IQKeyboardManager.sharedManager().enable = true
		if App.instance.userData.accessToken != nil {
			ARSLineProgress.show() //TODO: - add after view is loaded -
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
					if let notification = launchOptions?[.remoteNotification] as? [String: AnyObject]{
						let aps = notification["aps"] as! [String: AnyObject]
						//let aps = userInfo["aps"] as! [String: AnyObject]
						let custom  = aps["alert"]! as? NSDictionary
						print("remote notification Data: \(aps)")
						var i = 0
						//let custom  = aps["alert"]! as? NSDictionary
						switch custom?["loc-key"] as! String {
						case "LIKE":
							print("is like custom[loc-key]")
							(self.window?.rootViewController as? UITabBarController)?.selectedIndex = 1
							break
						case "COMMENT":
							(self.window?.rootViewController as? UITabBarController)?.selectedIndex = 1
							i = 3
							break
						case "PROFILE":
							print("is PROFILE custom[loc-key]")
							i = 4
							break
						case "BALADE":
							print("is BALADE custom[loc-key]")
							i = 0
							if let postId = notification["post_number"] {
								self.postID = postId as? Int
							}
							// FIXME: - value of postID here -
							//postID = 85
							(self.window?.rootViewController as? UITabBarController)?.selectedIndex = 0
							break
						default:
							i = 0
						}
						
					}else if App.instance.userModel?.animals?.isEmpty == false {
						print("Already setup welcome controller")
						self.window?.rootViewController = initialViewController
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
					if err._code != NSURLErrorTimedOut{
					print(err)
						App.instance.logout()
					}else{
						alert.showAlertError(title: "Erreur de connexion", subTitle: "s'il vous plaît vérifier votre connexion internet")
					}
			}
		}
		//  Fabric.with([Answers.self])
		// Fabric.with([Crashlytics.self])
		UNUserNotificationCenter.current().requestAuthorization(options:[.badge, .alert, .sound], completionHandler: { _,_ in
			//application.registerForRemoteNotifications()
			DispatchQueue.main.async {
				UIApplication.shared.registerForRemoteNotifications()
			}
		})
		return true
	}
	func application(_ application: UIApplication, open url: URL, sourceApplication: String?,  annotation: Any) -> Bool {
		return FBSDKApplicationDelegate.sharedInstance().application(application, open: url, sourceApplication: sourceApplication, annotation: annotation)
	}
	
	func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
		print("recibiendo Notificacion en ")
		let aps = userInfo["aps"] as! [String: AnyObject]
		let custom  = aps["alert"]! as? NSDictionary
		print("el valor de Custom: \(String(describing: custom))")
		
		var i = 0
		switch custom?["loc-key"] as! String {
		case "LIKE":
			print("is like custom[loc-key]")
			i = 1
			break
		case "COMMENT":
			print("is COMMENT custom[loc-key]")
			i = 3
			break
		case "PROFILE":
			print("is PROFILE custom[loc-key]")
			i = 4
			break
		case "BALADE":
			print("is BALADE custom[loc-key]")
			i = 0
			if let postId = userInfo["post_number"] {
				postID = postId as? Int
			}
			// FIXME: - value of postID here -
			//postID = 85
			break
		default:
			i = 0
		}
		if application.applicationState == .active {
			print("app active State")
			//let custom = aps["custom_data"] as! [String: AnyObject]
			//alert.showAlertSuccess(title: custom?["title"] as! String + "sent you a Message", subTitle: aps["body"] as! String)
			let view = MessageView.viewFromNib(layout: .CardView)
			view.configureTheme(.success)
			view.configureDropShadow()
			let iconText = ["🐶"].sm_random()!
			view.configureContent(title: custom!["title"] as! String, body: custom!["body"] as! String, iconText: iconText)
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
			print("App Foreground State:\(i)")
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

