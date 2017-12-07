//
//  BaladeViewController.swift
//  AnimalsMeet
//
//  Created by gwendal lasson on 08/06/2017.
//  Copyright © 2017 AnimalsMeet. All rights reserved.
//

import UIKit
import SwiftyJSON
class BaladeViewController: UIViewController, UITextViewDelegate {
   
   @IBOutlet weak var distanceSlider: UISlider!
   @IBOutlet weak var distance: UILabel!
   @IBOutlet weak var followedFriends: UISwitch!
   @IBOutlet weak var baladeDescription: UITextView!
   
   @IBOutlet weak var startButton: UIButton!
   
   var animalId: Int!
   var userJson = [JSON]()
   override func viewDidLoad() {
     super.viewDidLoad()
     baladeDescription.delegate = self
     self.sliderChanged(distanceSlider)
     loadUser()
   }
   
   @IBAction func sliderChanged(_ sender: UISlider) {
//      let value = String(format: "%.2f", sender.value)
      distance.text = "\(Int(sender.value * 1000)) m"
   }
   
   @IBAction func send(_ sender: Any) {
    _ = Api.instance.post("/hike", withParams: ["hike[content]" : baladeDescription.text! != "" ? baladeDescription.text! : "", "hike[sendFriends]" :followedFriends.isOn, "hike[animal_id]" :  App.instance.userData.selectedAnimal, "hike[distanceInKm]" : Int(distanceSlider.value)])
         .then { _ in alert.showAlertSuccess(title: "Succès", subTitle: "La balade a été créée") }
         .catch { _ in alert.showAlertError(title: "Erreur", subTitle: "Une erreur est survenue en créant la balade") }
   }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == " ",let lastWord = textView.text.components(separatedBy: " ").last, lastWord.hasPrefix("@"), let lastWordRange = (textView.text as NSString?)?.range(of: lastWord){
            if self.search(in: lastWord), searchDuplicate(this: lastWord) == 1  {
                let attributes = [NSForegroundColorAttributeName: UIColor.blue, NSFontAttributeName: self.baladeDescription.font!] as [String : Any]
                let attributedString = NSMutableAttributedString(string: lastWord, attributes: attributes)
                textView.textStorage.replaceCharacters(in:lastWordRange, with:attributedString)
                
            }else{
                print(searchDuplicate(this: lastWord))
                if searchDuplicate(this: lastWord) > 1 {
                    let lastWordRange = (textView.text as NSString?)?.range(of: lastWord, options: [.backwards])
                    textView.textStorage.replaceCharacters(in: lastWordRange!, with: "")
                }else {
                    let realLW = lastWord.replacingOccurrences(of: "@", with: "")
                    textView.textStorage.replaceCharacters(in:lastWordRange, with:realLW)
                }
            }
        }
        return true
        
    }
    func loadUser(){
        let endpoint = "/user"
        Api.instance.get(endpoint).then {JSON in
            // print("the Json in response promise \(JSON)")
            self.userJson =  JSON["users"].arrayValue
        }
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
                //let localA = ["id": userJson[i]["id"].stringValue, "nickname":userJson[i]["nickname"].stringValue]
                //arrayId.append(localA)
                //arrayId.insert(<#T##newElement: Dictionary<String, String>##Dictionary<String, String>#>, at: <#T##Int#>)
                return true
            }
        }
        print(false)
        return false
    }
    func searchDuplicate(this word: String) -> Int{
        var i = 0
        let words = baladeDescription.text.components(separatedBy: " ")
        for oneword in words {
            if oneword.contains(word){
                i += 1
            }
        }
        return i
    }
    /*func formatText(){
        let attributedText = NSMutableAttributedString()
        //if text == " ",let lastWord = textView.text.components(separatedBy: " ").last,
        let words = legend.components(separatedBy: " ")
        for word in words/*.filter({
             $0.hasPrefix("@")
             })*/{
                //  let lastWordRange =  legend.range(of: word)
                if word.hasPrefix("@"){
                    let attributes = [NSForegroundColorAttributeName: UIColor.blue, NSFontAttributeName: self.textView.font!] as [String : Any]
                    let attributedString = NSMutableAttributedString(string: word, attributes: attributes)
                    attributedText.append(attributedString)
                    attributedText.append(" ")
                }else{
                    attributedText.append(word)
                    attributedText.append(" ")
                    
                }
                self.textView.attributedText = attributedText
        }
    }*/

}
