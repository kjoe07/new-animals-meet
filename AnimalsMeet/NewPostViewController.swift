//
//  NewPostViewController.swift
//  AnimalsMeet
//
//  Created by Adrien morel on 06/06/2017.
//  Copyright © 2017 AnimalsMeet. All rights reserved.
//

import UIKit
import Fusuma
import ARSLineProgress
import PromiseKit

class NewPostViewController: UIViewController, FusumaDelegate, UITextViewDelegate {
   
   @IBOutlet weak var profilePic: UIImageView!
   //@IBOutlet weak var text: UITextView!
   @IBOutlet weak var picIcon: UIImageView!
   @IBOutlet weak var sendButton: UIBarButtonItem!
    @IBOutlet weak var text: UILabel!
    @IBOutlet weak var textView: UIView!
   
   @IBOutlet weak var photoWidthConstraint: NSLayoutConstraint!
//   @IBOutlet weak var textImageLeadingAligned: NSLayoutConstraint!
//   @IBOutlet weak var textSuperviewLeadingAligned: NSLayoutConstraint!
   
   var newMedia: MediaModel!
    var legend: String!
    var arrayId = [String]()
    //MARK: - ViewDidLoad -
    override func viewDidLoad() {
        super.viewDidLoad()
        
        profilePic.kf.setImage(with: App.instance.userModel.image)
        profilePic.layer.cornerRadius = 8
        picIcon.onTap { _ in
            let vc = FusumaViewController()
            vc.delegate = self
            vc.hasVideo = false
            self.present(vc, animated: true)
        }
        
        textView.onTap { _ in
          //  if self.newMedia != nil {
                self.performSegue(withIdentifier: "NewLegend", sender: nil)
                
          //  }
        }
    }
    //MARK: - Navigation -
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let controller = segue.destination as? LegendViewController, segue.identifier == "NewLegend" {
            controller.delegate = self
            controller.legend = legend
        }
    }
 
   @IBAction func stop(_ sender: Any) {
      dismiss(animated: true, completion: nil)
   }
   
   func getAnimal() -> AnimalModel {
      return App.instance.userModel.animals![App.instance.userData.selectedAnimal]
   }
   
   func addPicture() {
      let fusuma = FusumaViewController()
      fusuma.delegate = self
      fusuma.hasVideo = false
      fusuma.allowMultipleSelection = false
      self.present(fusuma, animated: true, completion: nil)
   }
    //MARK: - Send Functions -
    @IBAction func send(_ sender: Any) {
        
        sendButton.isEnabled = false
        ARSLineProgress.show()
        
        if newMedia != nil {
            postPicture(description: text.text)
        } else if let t = text.text, !t.isEmpty {
            sendPost()
        } else {
            sendButton.isEnabled = true
            ARSLineProgress.hide()
        }
    }
   func postPicture(description: String?) {
      
      newMedia.description = text.text
      
      newMedia.callForCreate(taggedUser: self.arrayId).then { _ -> Void in
         alert.showAlertSuccess(title: "Nouvelle image", subTitle: "Votre photo a été postée")
         self.stop(self)
         }.always {
            ARSLineProgress.hide()
         }.catch { err in
            self.sendButton.isEnabled = true
            App.showRequestFailure(err)
      }
   }
   
   func sendPost() {
    _ = Api.instance.post("/media/createPost", withParams: ["content": text.text, "animal_id": getAnimal().id!, "users": self.arrayId])
         .then { _ -> () in
            alert.showAlertSuccess(title: "Succès", subTitle: "Votre post a été envoyé !")
            self.stop(self)
         }
         .always {
            ARSLineProgress.hide()
         }
         .catch { _ in
            alert.showAlertError(title: "Erreur", subTitle: "Impossible d'envoyer le post")
            self.sendButton.isEnabled = true
      }
   }
   
   
   //MARK: - Fusuma -
   /* Fusuma */
   public func fusumaImageSelected(_ image: UIImage, source: FusumaMode) {
      
      let imageData:Data = UIImageJPEGRepresentation(image, 0.3)!
      newMedia = MediaModel()
      
      let user = App.instance.userModel!
      newMedia.author = user
      newMedia.animal = getAnimal()
      newMedia.rawData = imageData.base64EncodedString(options: .lineLength64Characters) // TODO: specify animal
      picIcon.image = image
      picIcon.layer.cornerRadius = 4
      
      self.photoWidthConstraint.isActive = false
      self.text.text = "Écrire une légende…"
      //self.textSuperviewLeadingAligned.isActive = false
//      self.textImageLeadingAligned.isActive = true
   }
   
   func fusumaDismissedWithImage(_ image: UIImage) {}
   func fusumaVideoCompleted(withFileURL fileURL: URL) {}
   func fusumaCameraRollUnauthorized() {}
   func fusumaDismissedWithImage(_ image: UIImage, source: FusumaMode) {}
   func fusumaMultipleImageSelected(_ images: [UIImage], source: FusumaMode) {}
   @objc func fusumaClosed() {}
   @objc func fusumaWillClosed() {}
   
    
}

extension NewPostViewController: NewLegend {
    func legend(legend: String, array: [String]) {
        self.legend = legend
        self.arrayId = array
        //text.text = legend
        let attributedText = NSMutableAttributedString()
        //if text == " ",let lastWord = textView.text.components(separatedBy: " ").last,
        let words = legend.components(separatedBy: " ")
        for word in words/*.filter({
            $0.hasPrefix("@")
        })*/{
          //  let lastWordRange =  legend.range(of: word)
            if word.hasPrefix("@"){
                let attributes = [NSForegroundColorAttributeName: UIColor.blue, NSFontAttributeName: self.text.font!] as [String : Any]
                let attributedString = NSMutableAttributedString(string: word, attributes: attributes)
               attributedText.append(attributedString)
                attributedText.append(" ")
            }else{
                attributedText.append(word)
                attributedText.append(" ")
                
            }
            text.attributedText = attributedText
            //(legend as? NSString)?.range(of: <#T##String#>)
            //lastWord.contains("@"), let lastWordRange = (textView.text as? NSString)?.range(of: lastWord){
            //text.attributedText
            //text.textStorage.replaceCharacters(in:lastWordRange, with:attributedString)
        }
        
    }
}
