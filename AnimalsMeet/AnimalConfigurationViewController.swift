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
import SwiftMessages

class AnimalConfigurationViewController: UIViewController, UITextFieldDelegate, FusumaDelegate {
   
   @IBOutlet var ask_name: UITextField!
   @IBOutlet var ask_age: UITextField!
   @IBOutlet var ask_male: UISwitch!
   @IBOutlet var ask_femele: UISwitch!
   @IBOutlet weak var ask_crossed: UISwitch!
   
   @IBOutlet var ask_loof: UISwitch!
   @IBOutlet var ask_dog: UISwitch!
   @IBOutlet var ask_cat: UISwitch!
   @IBOutlet var race: UIButton!
   @IBOutlet var profilePic: UIImageView!
   
   @IBOutlet weak var maleIconView: UIImageView!
   @IBOutlet weak var femaleIconView: UIImageView!
   @IBOutlet weak var crossedIcon: UIImageView!
   
   @IBOutlet var create_edit_button: UIButton!
   
   var onSuccess: (() -> Void)?
   
   var picHaveChanged = false
   var animal: AnimalModel!
   var newAnimal = false
   
   class func newInstance(animal: AnimalModel? = nil) -> AnimalConfigurationViewController {
      let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "AnimalSetupVC") as! AnimalConfigurationViewController
      vc.animal = animal
      return vc
   }
   
   override func viewDidLoad() {
      super.viewDidLoad()
      
      // TODO: use this icon from the storyboard like the other two
      let side: CGFloat = 20
      let size = CGSize(width: side, height: side)
      
      let crossedImage = FAKIonIcons.transgenderIcon(withSize: side)
      let maleImage = FAKIonIcons.maleIcon(withSize: side)
      let femaleImage = FAKIonIcons.femaleIcon(withSize: side)
      
      [crossedImage, maleImage, femaleImage].forEach {
         $0?.setAttributes([NSForegroundColorAttributeName: #colorLiteral(red: 0.431372549, green: 0.431372549, blue: 0.431372549, alpha: 1)])
      }
      
      self.crossedIcon.image = crossedImage?.image(with: size)
      self.maleIconView.image = maleImage?.image(with: size)
      self.femaleIconView.image = femaleImage?.image(with: size)
      
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
		self.profilePic.image = nil
      }
   }
   
   override func viewWillAppear(_ animated: Bool) {
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
      
	
      
      if animal == nil {
         create_edit_button.setTitle("Créer l'animal", for: .normal)
         animal = AnimalModel()
         newAnimal = true
      } else {
         create_edit_button.setTitle("Enregister l'animal", for: .normal)
		if (animal.id) != nil{
			let round: CGFloat = profilePic.bounds.height * 0.5
			UIKitViewUtils.setCornerRadius(sender: profilePic, radius: round)
		}
      }
   }
   
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
   
   
   @IBAction func action_cat(_ sender: AnyObject) {
      ask_dog.setOn(!ask_cat.isOn, animated: true)
   }
   
   @IBAction func action_dog(_ sender: AnyObject) {
      ask_cat.setOn(!ask_dog.isOn, animated: true)
   }
   
   @IBAction func action_femele(_ sender: AnyObject) {
      ask_male.setOn(!ask_femele.isOn, animated: true)
   }
   
   @IBAction func action_male(_ sender: AnyObject) {
      ask_femele.setOn(!ask_male.isOn, animated: true)
   }
   
   var currentSync: Promise<Void>?
   
   @IBAction func sendRequest(_ sender: Any) {
      
      let media = MediaModel()
      
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
      
      // TODO: Send crossed value
      
      animal.name = ask_name.text!
      animal.year = ask_age.text!
      animal.loof = ask_loof.isOn
      
      
      // TODO        selectedBreeds
      
	
      
      if profilePic.image == nil {
         alert.showAlertError(title: "Attention", subTitle: "Veuillez choisir une photo de profil")
      } else if animal.name.characters.count <= 1 {
         alert.showAlertError(title: "Attention", subTitle: "Veuillez saisir un nom")
      } else if animal.year.characters.count == 0 {
         alert.showAlertError(title: "Attention", subTitle: "Veuillez saisir son age")
      } else if animal.breed == nil {
         alert.showAlertError(title: "Attention", subTitle: "Veuillez choisir une race")
      } else {
		let imageData = UIImageJPEGRepresentation(profilePic.image!, 0.3)!
		media.rawData = imageData.base64EncodedString(options: .lineLength64Characters)
		media.animal = animal
         alert.showProgressAlert(title: "Chargement en cours", subTitle: "Enregistrement de l'animal...")
         
         var animalSync = self.newAnimal  ? self.animal.syncCreate().then { json -> Void in
			print("create animal")
               self.animal.id = json["myanimal"]["id"].intValue
            }
            : self.animal.sync().then { json -> Void in
				print("update animal")
//               self.animal.id = json["id"].intValue
            }
         
//         animalSync = animalSync.then {
//            media.animal.id = self.animal.id
//         }
         
         
         if picHaveChanged {
			print("mando a crear una foto")
            animalSync = animalSync.then {
               // create new media object associated to the animal
               return media.callForCreate(taggedUser: nil)
               .then { json -> Void in
                     self.animal.profilePicMediaId = Int(json["id"].stringValue)
               }
               .then {  // sync animal avatar
                  return self.animal.sync().then { _ -> Void in }
               }
			}.catch { error in
				print(error)
				alert.showAlertError(title: "Erreur", subTitle: "Un problème est survenu. Veuillez réessayer.")
			}
         }
         
         self.currentSync = animalSync.always {
            SwiftMessages.hideAll()
         }.then { () -> Void in
            alert.showAlertSuccess(title: "Félicitation", subTitle: "Votre animal vient d'être créé")
            
            if self.newAnimal {
               App.instance.userModel.animals!.insert(self.animal, at: 0)
               App.instance.userData.selectedAnimal = 0
            }
         }.catch { error in
            print(error)
            alert.showAlertError(title: "Erreur", subTitle: "Un problème est survenu. Veuillez réessayer.")
         }.then {
            self.onSuccess?()
         }
      }
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
