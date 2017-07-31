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

class NewPostViewController: UIViewController, FusumaDelegate {

    @IBOutlet weak var profilePic: UIImageView!
    @IBOutlet weak var text: UITextView!
    @IBOutlet weak var picIcon: UIImageView!
    @IBOutlet weak var sendButton: UIBarButtonItem!
    
    var newMedia: MediaModel!
    
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
    
    func postPicture(description: String?) {
        
        newMedia.description = text.text
        
        newMedia.callForCreate().then { _ -> Void in
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
        _ = Api.instance.post("/media/createPost", withParams: ["content": text.text, "animal_id": getAnimal().id!])
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
    
    @IBAction func send(_ sender: Any) {
        
        sendButton.isEnabled = false
        ARSLineProgress.show()
        
        if newMedia != nil {
            postPicture(description: text.text)
        } else if !text.text.isEmpty {
            sendPost()
        } else {
            sendButton.isEnabled = true
            ARSLineProgress.hide()
        }
    }
    
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
    }
    
    func fusumaDismissedWithImage(_ image: UIImage) {}
    func fusumaVideoCompleted(withFileURL fileURL: URL) {}
    func fusumaCameraRollUnauthorized() {}
    func fusumaDismissedWithImage(_ image: UIImage, source: FusumaMode) {}
    func fusumaMultipleImageSelected(_ images: [UIImage], source: FusumaMode) {}
    @objc func fusumaClosed() {}
    @objc func fusumaWillClosed() {}
    
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
    }
}
