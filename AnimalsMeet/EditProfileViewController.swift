//
//  EditProfileViewController.swift
//  AnimalsMeet
//
//  Created by Reynaldo Aguilar on 8/28/17.
//  Copyright © 2017 AnimalsMeet. All rights reserved.
//

import UIKit
import FontAwesomeKit
import Fusuma
import PromiseKit
import SwiftMessages

class EditProfileViewController: UIViewController, FusumaDelegate, UITextFieldDelegate {
   @IBOutlet weak var nameField: UITextField!
   @IBOutlet weak var nicknameField: UITextField!
   @IBOutlet weak var avatarImageView: UIImageView!
   @IBOutlet weak var saveButton: UIButton!
   
   var onSuccess: (() -> Void)?
   
   var user: UserModel!
   
   var avatarChanged: Bool = false {
      didSet {
         self.saveButton.isEnabled = contentChanged || avatarChanged
      }
   }
   
   var contentChanged: Bool = false {
      didSet {
         self.saveButton.isEnabled = contentChanged || avatarChanged
      }
   }
   
   class func newInstance() -> EditProfileViewController {
      let storyboard = UIStoryboard(name: "Main", bundle: .main)
      let controller = storyboard.instantiateViewController(
         withIdentifier: "EditProfileViewController"
      )
      
      guard let editController = controller as? EditProfileViewController else {
         fatalError()
      }
      
      return editController
   }
   
   override func viewDidLoad() {
      super.viewDidLoad()
      // MARK: customize UI elements
      
      let side: CGFloat = 28
      let size = CGSize(width: 30, height: 30)
      
      let userIcon = FAKFontAwesome.userIcon(withSize: side)
      let lockIcon = FAKFontAwesome.lockIcon(withSize: side)
      
      [userIcon, lockIcon].forEach {
         $0?.drawingPositionAdjustment = UIOffset(horizontal: 1, vertical: 0)
         
         $0?.addAttribute(
            NSForegroundColorAttributeName,
            value: UIColor(white: 0.3, alpha: 1)
         )
      }
      
      nameField.leftView = UIImageView(image: userIcon?.image(with: size))
      nameField.leftViewMode = .always
      nameField.addTarget(
         self,
         action: #selector(self.contentDidChange(sender:)),
         for: .editingChanged
      )
      
      nicknameField.leftView = UIImageView(image: lockIcon?.image(with: size))
      nicknameField.leftViewMode = .always
      nicknameField.addTarget(
         self,
         action: #selector(self.contentDidChange(sender:)),
         for: .editingChanged
      )
      
      saveButton.isEnabled = false
      
      UIKitViewUtils.setCornerRadius(sender: saveButton, radius: 8)
      avatarImageView.rounded()
      
      // MARK: populating user data
      guard let user = App.instance.userModel else { fatalError() }
      
      self.user = user
      nameField.text = user.name
      nicknameField.text = user.nickname
      
      if user.image != nil {
         self.avatarImageView.kf.setImage(
            with: user.image,
            placeholder: nil,
            options: [.transition(.fade(1))],
            progressBlock: nil,
            completionHandler: nil
         );
      }
   }
   
   func contentDidChange(sender: Any) {
      contentChanged = nameField.text != user.name || nicknameField.text != user.nickname
   }
   
   @IBAction func changeImage(_ sender: Any) {
      let fusuma = FusumaViewController()
      fusuma.delegate = self
      fusuma.hasVideo = false
      fusuma.allowMultipleSelection = false
      self.present(fusuma, animated: true, completion: nil)
   }
   
   @IBAction func saveChanges(_ sender: Any) {
      guard contentChanged || avatarChanged else { return }

      guard nameField.text!.characters.count > 1 else {
         alert.showAlertError(title: "Attention", subTitle: "Veuillez saisir un nom")
         return
      }
      
      guard nicknameField.text!.characters.count > 1 else {
         alert.showAlertError(
            title: "Attention",
            subTitle: "Veuillez saisir un nom d' utilisateur"
         )
         
         return
      }
      
      var avatarPromise = Promise<Void>(value: ())
      
      if let image = self.avatarImageView.image, avatarChanged {
         avatarPromise = avatarPromise.then { _ -> Promise<Void> in
            let imageData = UIImageJPEGRepresentation(image, 0.3)!
            
            let media = MediaModel()
            media.rawData = imageData.base64EncodedString(options: .lineLength64Characters)
            return media.callForCreate(taggedUser: nil).then { json -> Void in
               let createdMedia = MediaModel(fromJSON: json)
               self.user.image = createdMedia.url
            }
         }
      }
      
      var infoPromise = Promise<Void>(value: ())
      
      if contentChanged {
         infoPromise = infoPromise.then { _ -> Promise<Void> in
            return UserModel.updateChanges(
               name: self.nameField.text ?? "",
               nickname: self.nicknameField.text ?? ""
               ).then { _ -> Void in }
         }
      }
      
      alert.showProgressAlert(title: "Chargement en cours", subTitle: "Modifier le profil...")
      
      when(fulfilled: avatarPromise, infoPromise)
         .always {
            SwiftMessages.hideAll()
         }
         .then { _ -> Void in
            self.user.name = self.nameField.text
            self.user.nickname = self.nicknameField.text
            self.avatarChanged = false
            self.contentChanged = false
            
            alert.showAlertSuccess(title: "Félicitation", subTitle: "Votre profil vient d'être modifié")
            
            self.onSuccess?()
         }.catch { error in
            print(error)
            alert.showAlertError(title: "Erreur", subTitle: "Un problème est survenu. Veuillez réessayer.")
         }
   }
   
   func fusumaImageSelected(_ image: UIImage, source: FusumaMode) {
      avatarImageView.image = image
      avatarChanged = true
   }
   
   func fusumaVideoCompleted(withFileURL fileURL: URL) {}
   func fusumaCameraRollUnauthorized() {}
   func fusumaMultipleImageSelected(_ images: [UIImage], source: FusumaMode) { }
}
