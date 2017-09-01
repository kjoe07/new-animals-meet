//
//  user_session.swift
//  AnimalsMeet
//
//  Created by Sacha IFRAH on 04/10/2016.
//  Copyright © 2016 AnimalsMeet. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import SwiftMessages
import SwiftyJSON
import PromiseKit

import FBSDKLoginKit
import Haneke

class LoginViewController: UIViewController {
   
   @IBOutlet var input_email: UITextField!
   @IBOutlet var input_password: UITextField!
   @IBOutlet var input_connect: UIButton!
   @IBOutlet var input_fb: UIButton!
   @IBOutlet var input_register: UIButton!
   @IBOutlet weak var cgu: UILabel!
   
   let fbLoginManager: FBSDKLoginManager = FBSDKLoginManager()
   
   func enterTheApp() {
      
      guard let window = UIApplication.shared.keyWindow else { fatalError() }
      
      let storyboard = UIStoryboard(name: "Main", bundle: nil)
      let initialViewController = storyboard.instantiateViewController(withIdentifier: "TabBarVC")
      //        UIApplication.shared.keyWindow?.rootViewController = initialViewController
      //        UIApplication.shared.keyWindow?.makeKeyAndVisible()
      
      if App.instance.userModel?.animals?.isEmpty == false {
         print("Already setup welcome controller")
         window.rootViewController = initialViewController
      }
      else {
         print("Should display welcome controller")
         let controller = EditProfileViewController.newInstance()
         controller.title = "Enregister le profil"
         
         controller.onSuccess = {
            let animalConfigVC = AnimalConfigurationViewController.newInstance()
            
            animalConfigVC.onSuccess = {
               window.rootViewController = initialViewController
            }
            
            controller.navigationController?.pushViewController(animalConfigVC, animated: true)
         }
         
         let navigation = UINavigationController(rootViewController: controller)
         window.rootViewController = navigation
      }
   }
   
   @IBAction func auth_facebook(_ sender: AnyObject) {
      
      let permissionsArray = ["public_profile", "email"]
      
      fbLoginManager.logIn(withReadPermissions: permissionsArray, from: self) { response, error in
         
         if error != nil {
            alert.showAlertError(title: "Oops", subTitle: "facebook auth failed")
            
         } else if response!.isCancelled {
            alert.showAlertError(title: "Facebook authentification", subTitle: "Failed")
            
         } else {
            
            App.instance.authenticate(facebookToken: response!.token.tokenString)
               .then { _ -> Void in
                  self.enterTheApp()
               }.catch { err in
                  alert.showAlertError(title: "Authentification", subTitle: "La connexion avec Facebook n'a pas fonctionné. (\(err))")
            }
         }
      }
   }
   
   @IBAction func execLogin(_ sender: AnyObject) {
      
      App.instance.authenticate(email: input_email.text!, password: input_password.text!)
         .then { _ -> Void in
            self.enterTheApp()
         }
         .catch { err in
            alert.showAlertError(title: "Authentification", subTitle: "Votre email ou mot de passe est invalide")
      }
   }
   
   func initForm() {
      let radius: CGFloat = view.bounds.height * 0.07 * 0.5
      
      // init input_mail
      UIKitViewUtils.setCornerRadius(sender: input_email, radius: radius)
      UIKitViewUtils.setBorderWidth(sender: input_email, width: 1.5, hexString: "#cccccc")
      
      // init input_password
      UIKitViewUtils.setCornerRadius(sender: input_password, radius: radius)
      UIKitViewUtils.setBorderWidth(sender: input_password, width: 1.5, hexString: "#cccccc")
      
      // init input_connect
      UIKitViewUtils.setCornerRadius(sender: input_connect, radius: radius)
      
      // init input_fb
      UIKitViewUtils.setCornerRadius(sender: input_fb, radius: radius)
      
      // init input_register
      UIKitViewUtils.setCornerRadius(sender: input_register, radius: radius)
   }
   
   override func viewWillAppear(_ animated: Bool) {
      initForm()
      
      cgu.onClick {
         let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "cgu")
         self.present(vc, animated: true, completion: nil)
      }
   }
}
