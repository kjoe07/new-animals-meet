//
//  myaccount.swift
//  AnimalsMeet
//
//  Created by Sacha IFRAH on 07/11/2016.
//  Copyright © 2016 AnimalsMeet. All rights reserved.
//

import Foundation
import UIKit
import Kingfisher
import FBSDKLoginKit
import FBSDKShareKit
import FBSDKCoreKit
import Sensitive
import MessageUI
import Fusuma
import Haneke
import SwiftyJSON

class myaccount: UIViewController, MFMailComposeViewControllerDelegate, FusumaDelegate {
   
   @IBOutlet var name: UILabel!
   @IBOutlet var profil_pic: UIImageView!
   @IBOutlet var provider: UILabel!
   
   var user: UserModel!
   
   override func viewDidLoad() {
      user = App.instance.userModel
      
      self.provider.text = user.provider
      self.name.text = user.nickname
      
      self.view.onSwipe(to: .right) { (swipeGestureRecognizer) -> Void in
         self.navigationController?.popToRootViewController(animated: true)
      }
   }
   
   override func viewWillAppear(_ animated: Bool) {
      super.viewWillAppear(animated)
      loadPic()
   }
   
   override func viewDidLayoutSubviews() {
      super.viewDidLayoutSubviews()
      
      profil_pic.rounded()
   }
   
   func loadPic() {
      if user.image != nil {
         self.profil_pic.kf.indicatorType = .activity
         
         self.profil_pic?.kf.setImage(
            with: user.image,
            placeholder: self.profil_pic.image,
            options: [.transition(.fade(1))],
            progressBlock: nil,
            completionHandler: { [weak self] _, _, _, _ in
               self?.profil_pic.rounded()
            }
         );
      }
   }
   
   @IBAction func sendPicture(_ sender: Any) {
      let fusuma = FusumaViewController()
      fusuma.delegate = self
      fusuma.hasVideo = false
      fusuma.allowMultipleSelection = false
      self.present(fusuma, animated: true, completion: nil)
   }
   
   
   func fusumaImageSelected(_ image: UIImage, source: FusumaMode) {
      
      let imageData = UIImageJPEGRepresentation(image, 0.3)!
      
      let media = MediaModel()
      media.rawData = imageData.base64EncodedString(options: .lineLength64Characters)
      media.callForCreate(taggedUser: nil).then { _ -> Void in
         self.loadPic()
         alert.showAlertSuccess(title: "Nouvelle image", subTitle: "Votre photo a été enregistré")
         }.catch(execute: App.showRequestFailure)
   }
   
   func fusumaVideoCompleted(withFileURL fileURL: URL) {}
   func fusumaCameraRollUnauthorized() {}
   func fusumaDismissedWithImage(_ image: UIImage, source: FusumaMode) {}
   func fusumaClosed() {}
   func fusumaWillClosed() {}
   func fusumaMultipleImageSelected(_ images: [UIImage], source: FusumaMode) { }
   
   @IBAction func logoutNow(_ sender: Any) {
      let loginManager = FBSDKLoginManager()
      loginManager.logOut()
      App.instance.userData.accessToken = nil
      
      let storyboard = UIStoryboard(name: "Main", bundle: nil)
      let authVC = storyboard.instantiateViewController(withIdentifier: "auth_view")
      UIApplication.shared.delegate?.window??.rootViewController = authVC
   }
   
   @IBAction func startSupport(_ sender: Any) {
      if MFMailComposeViewController.canSendMail() {
         let mail = MFMailComposeViewController()
         mail.mailComposeDelegate = self
         mail.setToRecipients(["support@animals-meet.com"])
         mail.setSubject("")
         mail.setMessageBody("", isHTML: true)
         present(mail, animated: true, completion: nil)
      } else {
         // show failure alert
      }
   }
   
   func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
      controller.dismiss(animated: true, completion: nil)
   }
   
   func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
      controller.dismiss(animated: true, completion: nil)
   }
}
