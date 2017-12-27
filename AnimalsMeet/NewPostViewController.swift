//
//  NewPostViewController.swift
//  AnimalsMeet
//
//  Created by Yoel Jimenez del Valle  12/27/2017.
//  Copyright © 2017 AnimalsMeet. All rights reserved.
//

import UIKit
import Fusuma
import ARSLineProgress
import PromiseKit
import CZPicker
import SwiftyJSON
class NewPostViewController: UIViewController, FusumaDelegate, UITextViewDelegate {
   
   @IBOutlet weak var profilePic: UIImageView!
   @IBOutlet weak var text: UITextView!
   @IBOutlet weak var picIcon: UIImageView!
   @IBOutlet weak var sendButton: UIBarButtonItem!
	// @IBOutlet weak var text: UILabel!
    @IBOutlet weak var textView: UIView!
   
   @IBOutlet weak var photoWidthConstraint: NSLayoutConstraint!
//   @IBOutlet weak var textImageLeadingAligned: NSLayoutConstraint!
//   @IBOutlet weak var textSuperviewLeadingAligned: NSLayoutConstraint!
	var newArrayId = [["id":"","nickname":""]]
	var id = [String]()
	let picker = CZPickerView(headerTitle: "Friends", cancelButtonTitle: "Cancel", confirmButtonTitle: "Confirm")
	var userJson = [JSON]()
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
		arrayId.removeAll()
		loadUser()
		
		picker?.delegate = self
		picker?.dataSource = self
		picker?.needFooterView = false
		text.delegate = self
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
        
        if newMedia != nil /*&& text.text == nil*/{
			print("sending a picture")
            postPicture(description: text.text)
        } else if let t = text.text, !t.isEmpty {
			print("send a post")
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
	//self.text.text = "Écrire une légende…"
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
	func loadUser(){
		let endpoint = "/user/\(App.instance.userModel.id!)/friends" //"/user" //
		Api.instance.get(endpoint).then {JSON in
			//print("the Json in response promise \(JSON)")
			self.userJson =  JSON["friends"].arrayValue
			}.always {
				self.picker?.reloadData()
		}
		/*let requestO = request()
		requestO.request(endpoint, withParams: [:], method: .get, completion: { data, error in
		if let data = data {
		print("la salida del data \(data["users"].arrayValue)")
		self.userJson = data["users"].arrayValue
		}
		})*/
	}
	func search(in word :String) -> Bool{
		let nword = word.replacingOccurrences(of: "@", with: "").lowercased()
		print("the search \(nword)")
		//print("the user json\(userJson)")
		print("total count \(userJson.count)")
		for i in 0..<userJson.count{
			//print("el subjson \(userJson[i])")
			if userJson[i]["nickname"].stringValue.lowercased().contains(nword){
				print(true)
				self.arrayId.append(userJson[i]["id"].stringValue)
				let localA = ["id": userJson[i]["id"].stringValue, "nickname":userJson[i]["nickname"].stringValue]
				newArrayId.append(localA)
				//arrayId.insert(<#T##newElement: Dictionary<String, String>##Dictionary<String, String>#>, at: <#T##Int#>)
				return true
			}
		}
		print(false)
		return false
	}
	func searchDuplicate(this word: String) -> Int{
		var i = 0
		let words = text.text.components(separatedBy: " ")
		for oneword in words {
			
			if oneword.contains(word){
				i += 1
			}
		}
		return i
	}
	func formatText(){
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
				self.text.attributedText = attributedText
		}
	}
	func textViewDidChangeSelection(_ textView: UITextView) {
		if let lastWord = text.text.components(separatedBy: " ").last, lastWord.hasPrefix("@"), let lastWordRange = (text.text as NSString?)?.range(of: lastWord){
			picker?.show()
			/*if self.search(in: lastWord), searchDuplicate(this: lastWord) == 1  {
			let attributes = [NSForegroundColorAttributeName: UIColor.blue, NSFontAttributeName: self.textView.font!] as [String : Any]
			let attributedString = NSMutableAttributedString(string: lastWord, attributes: attributes)
			textView.textStorage.replaceCharacters(in:lastWordRange, with:attributedString)
			}*/
		}
	}
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
extension NewPostViewController: CZPickerViewDelegate, CZPickerViewDataSource {
	/* func czpickerView(_ pickerView: CZPickerView!, imageForRow row: Int) -> UIImage! {
	if pickerView == pickerWithImage {
	return self.userJson[row]["image"].stringValue
	}
	return nil
	}*/
	
	func numberOfRows(in pickerView: CZPickerView!) -> Int {
		print(userJson.count)
		return userJson.count > 0 ? userJson.count : 1
	}
	
	func czpickerView(_ pickerView: CZPickerView!, titleForRow row: Int) -> String! {
		
		return userJson.count > 0 ? userJson[row]["name"].stringValue : "No friends for this User"
	}
	
	func czpickerView(_ pickerView: CZPickerView!, didConfirmWithItemAtRow row: Int){
		if userJson.count > 0 {
		print("aqui es adonde")
		print("el valor del row\(userJson[row].arrayValue)")
		//print(fruits[row])
		text.text.append(userJson[row]["nickname"].stringValue)
		if let lastWord = text.text.components(separatedBy: " ").last, lastWord.hasPrefix("@"), let lastWordRange = (text.text as NSString?)?.range(of: lastWord, options: .backwards){
			let attributes = [NSForegroundColorAttributeName: UIColor.blue, NSFontAttributeName: self.text.font!] as [String : Any]
			let attributedString = NSMutableAttributedString(string: "@"+userJson[row]["nickname"].stringValue, attributes: attributes)
			
			text.textStorage.replaceCharacters(in: lastWordRange, with: attributedString)
			self.search(in: userJson[row]["nickname"].stringValue)
		}
		self.navigationController?.setNavigationBarHidden(false, animated: true)
		}
		self.text.becomeFirstResponder()
	}
	
	func czpickerViewDidClickCancelButton(_ pickerView: CZPickerView!) {
		self.navigationController?.setNavigationBarHidden(false, animated: true)
	}
	
	@nonobjc func czpickerView(_ pickerView: CZPickerView!, didConfirmWithItemsAtRows rows: [AnyObject]!) {
		
		for row in rows {
			if let row = row as? Int {
				// print(fruits[row])
			}
		}
	}
}
