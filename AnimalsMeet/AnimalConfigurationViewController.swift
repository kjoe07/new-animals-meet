//
//  createOrEdit.swift
//  AnimalsMeet
//
//  Created by Sacha IFRAH on 31/10/2016.
//  Copyright © 2016 AnimalsMeet. All rights reserved.
//

import Foundation
import UIKit
import ImagePicker
import SwiftyBase64
import SwiftyJSON
import Kingfisher
import Sensitive
import PromiseKit
import Fusuma
import FontAwesomeKit

class AnimalConfigurationViewController: UIViewController, UITextFieldDelegate, FusumaDelegate {
   
   @IBOutlet var ask_name: UITextField!
   @IBOutlet var ask_age: UITextField!
   @IBOutlet var ask_male: UISwitch!
   @IBOutlet var ask_femele: UISwitch!
   @IBOutlet weak var ask_transgender: UISwitch!
   
   @IBOutlet var ask_loof: UISwitch!
   @IBOutlet var ask_dog: UISwitch!
   @IBOutlet var ask_cat: UISwitch!
   @IBOutlet var race: UIButton!
   @IBOutlet var profilePic: UIImageView!
   @IBOutlet weak var transgenderIcon: UIImageView!
   
   var picHaveChanged = false
   var animal: AnimalModel!
   var newAnimal = false
   
   class func newInstance(animal: AnimalModel? = nil) -> AnimalConfigurationViewController {
      let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "AnimalSetupVC") as! AnimalConfigurationViewController
      vc.animal = animal
      return vc
   }
   
   @IBOutlet var create_edit_button: UIButton!
   
   @IBAction func askPicture(_ sender: AnyObject) {
      let fusuma = FusumaViewController()
      fusuma.delegate = self
      fusuma.hasVideo = false
      fusuma.allowMultipleSelection = false
      self.present(fusuma, animated: true, completion: nil)
   }
   
   func fusumaImageSelected(_ image: UIImage, source: FusumaMode) {
      profilePic.image = image
      picHaveChanged = true
   }
   
   func fusumaVideoCompleted(withFileURL fileURL: URL) {}
   func fusumaCameraRollUnauthorized() {}
   func fusumaDismissedWithImage(_ image: UIImage, source: FusumaMode) {}
   func fusumaClosed() {}
   func fusumaWillClosed() {}
   func fusumaMultipleImageSelected(_ images: [UIImage], source: FusumaMode) { }
   
   
   @IBAction func askBreed(_ sender: Any) {
      
      var selection = [Int]()
      
      if animal != nil {
         selection = []
         if animal.breed != nil && animal.breed != 0 {
            selection.append(animal.breed)
         }
      }
      
      let breedListVC = BreedSelectorTableViewController.newInstance(selection: selection, max: 1) { breeds in
         
         if let breedId = breeds.first {
            self.animal.breed = breedId
            
            if let breed = App.instance.breeds.first(where: { $0.id == breedId }) {
               self.race.setTitle(breed.nameFr, for: .normal)
            }
            else {
               self.race.setTitle("Sélectionner une race", for: .normal)
            }
         }
         else {
            self.animal.breed = 0
            self.race.setTitle("Sélectionner une race", for: .normal)
         }
      }
      navigationController?.pushViewController(breedListVC, animated: true)
   }
   
   override func viewWillAppear(_ animated: Bool) {
//      let radius: CGFloat = ask_name.bounds.height * 0.3
      
//      UIKitViewUtils.setCornerRadius(sender: askCountry, radius: radius)
//      UIKitViewUtils.setBorderWidth(sender: askCountry, width: 1.5, hexString: "#cccccc")
      UIKitViewUtils.setCornerRadius(sender: race, radius: 8)
      UIKitViewUtils.setCornerRadius(sender: create_edit_button, radius: 7)
      
      ask_name.delegate = self
      ask_name.leftViewMode = .always
      let image = UIImageView(image: UIImage(named: "animal-prints"))
      image.frame = CGRect(x: 12, y: 9, width: 13.5, height: 12)
      ask_name.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 26, height: 0))
      ask_name.addSubview(image)
      
      ask_age.delegate = self
      ask_age.leftViewMode = .always
      let image2 = UIImageView(image: UIImage(named: "calendar"))
      image2.frame = CGRect(x: 12, y: 9, width: 13, height: 13)
      ask_age.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 26, height: 0))
      ask_age.addSubview(image2)
      
      let round: CGFloat = profilePic.bounds.height * 0.5
      UIKitViewUtils.setCornerRadius(sender: profilePic, radius: round)
      
      if animal == nil {
         create_edit_button.setTitle("Créer l'animal", for: .normal)
         animal = AnimalModel()
         newAnimal = true
      } else {
         create_edit_button.setTitle("Enregister l'animal", for: .normal)
      }
   }
   
   override func viewDidLoad() {
      super.viewDidLoad()
      
      // TODO: use this icon from the storyboard like the other two
      let transgenderImage = FAKFontAwesome.transgenderIcon(
         withSize: 16
      )
      transgenderImage?.setAttributes([NSForegroundColorAttributeName: #colorLiteral(red: 0.431372549, green: 0.431372549, blue: 0.431372549, alpha: 1)])
      
      self.transgenderIcon.image = transgenderImage?.image(with: CGSize(width: 16, height: 16))
      
      self.view.onSwipe(to: .right) { (swipeGestureRecognizer) -> Void in
         self.navigationController?.popToRootViewController(animated: true)
      }
      
      if animal != nil {
         
         ask_age.text = animal.year
         
         let dog = animal.type.contains("dog")
         ask_cat.setOn(!dog, animated: false)
         ask_dog.setOn(dog, animated: false)
         
         ask_male.setOn(animal.sex == .male, animated: false)
         ask_femele.setOn(animal.sex == .female, animated: false)
         ask_transgender.setOn(animal.sex == .transgender, animated: false)
         
         ask_loof.setOn(animal.loof, animated: true)
         ask_name.text = animal.name
         
         
         profilePic.kf.setImage(with: animal.profilePicUrl,
                                placeholder: nil,
                                options: [.transition(.fade(1))],
                                progressBlock: nil,
                                completionHandler: nil)
         title = "Modifier votre animal"
         
         
         if let breed = App.instance.breeds.first(where: { $0.id == animal.breed }) {
            self.race.setTitle(breed.nameFr, for: .normal)
         }
         else {
            self.race.setTitle("Sélectionner une race", for: .normal)
         }
         
      } else {
         title = "Nouvel animal"
      }
   }
   
   
   @IBAction func action_cat(_ sender: AnyObject) {
      ask_dog.setOn(!ask_cat.isOn, animated: true)
   }
   
   @IBAction func action_dog(_ sender: AnyObject) {
      ask_cat.setOn(!ask_dog.isOn, animated: true)
   }
   
   @IBAction func action_femele(_ sender: AnyObject) {
      ask_male.setOn(!ask_femele.isOn, animated: true)
      ask_transgender.setOn(false, animated: true)
   }
   
   @IBAction func action_male(_ sender: AnyObject) {
      ask_femele.setOn(!ask_male.isOn, animated: true)
      ask_transgender.setOn(false, animated: true)
   }
   
   @IBAction func action_transgender(_ sender: Any) {
      ask_femele.setOn(false, animated: true)
      ask_male.setOn(!ask_transgender.isOn, animated: true)
   }
   
   @IBAction func sendRequest(_ sender: Any) {
      
      let media = MediaModel()
      let defaults = UserDefaults.standard
      
      if ask_dog.isOn {
         animal.type = "dog"
      } else {
         animal.type = "cat"
      }
      
      if ask_male.isOn {
         animal.sex = .male
      } else if ask_femele.isOn {
         animal.sex = .female
      }
      else {
         animal.sex = .transgender
      }
      
      animal.name = ask_name.text!
      animal.year = ask_age.text!
      animal.loof = ask_loof.isOn
      
      
      // TODO        selectedBreeds
      
      let imageData = UIImageJPEGRepresentation(profilePic.image!, 0.3)!
      media.rawData = imageData.base64EncodedString(options: .lineLength64Characters)
      media.animal = animal
      
      if profilePic.image == nil {
         alert.showAlertError(title: "Attention", subTitle: "Veuillez choisir une photo de profil")
      } else if animal.name.characters.count <= 1 {
         alert.showAlertError(title: "Attention", subTitle: "Veuilliez saisir un nom")
      } else if animal.year.characters.count == 0 {
         alert.showAlertError(title: "Attention", subTitle: "Veuilliez saisir son age")
      } else if animal.breed == nil {
         alert.showAlertError(title: "Attention", subTitle: "Veuilliez choisir une race")
      } else {
         
         alert.showAlertWarning(title: "Chargement en cours", subTitle: "Enregistrement de l'animal...")
         
         var animalPromise = Promise<Void>(value: ())
         
         if picHaveChanged && !newAnimal {
            animalPromise = animalPromise.then { _ -> Promise<JSON> in
               return media.callForCreate()
               }.then { json -> Void in
                  self.animal.profilePicMediaId = Int(json["id"].stringValue)
            }
         }
         
         let promise: Promise<JSON> = newAnimal ?
            animalPromise.then { _ -> Promise<JSON> in self.animal.syncCreate() } :
            animalPromise.then { _ -> Promise<JSON> in self.animal.sync() }
         
         promise.then { (json: JSON) -> Void in // TODO: try not to call sync animal twice. TODO: gérer l'erreur si le media ne s'upload pa
            
            if self.newAnimal {
               self.animal.id = json["myanimal"]["id"].intValue
            } else {
               self.animal.id = json["id"].intValue
            }
            media.animal.id = self.animal.id
            
            if self.newAnimal {
               
               _ = media.callForCreate().then { json -> Promise<JSON> in
                  self.animal.profilePicMediaId = Int(json["id"].stringValue)
                  return self.animal.sync()
                  }.then { _ -> Void in
                     
                     
                     _ = self.navigationController?.popViewController(animated: true)
                     alert.showAlertSuccess(title: "Félicitation", subTitle: "Votre animal vient d'être créé")
                     App.instance.userModel.animals!.insert(self.animal, at: 0)
                     App.instance.userData.selectedAnimal = 0
               }
            } else {
               _ = self.navigationController?.popViewController(animated: true)
               alert.showAlertSuccess(title: "Félicitation", subTitle: "Votre animal vient d'être modifié")
            }
            }.catch { err in
               print(err)
               alert.showAlertError(title: "Erreur", subTitle: "Un problème est survenu. Veuillez réessayer.")
         }
      }
      
      func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) { // TODO: is it even used ?
         self.view.endEditing(true)
      }
      
      func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
         
         let currentCharacterCount = textField.text?.characters.count ?? 0
         if (range.length + range.location > currentCharacterCount){
            return false
         }
         let newLength = currentCharacterCount + string.characters.count - range.length
         
         if textField.keyboardType == .numberPad {
            return newLength <= 2
         }
         
         return newLength <= 15
      }
   }
}
