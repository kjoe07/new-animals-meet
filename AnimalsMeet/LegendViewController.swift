//
//  LegendViewController.swift
//  AnimalsMeet
//
//  Created by Marilyn on 9/26/17.
//  Copyright © 2017 AnimalsMeet. All rights reserved.
//

import UIKit
import PromiseKit
import SwiftyJSON
protocol NewLegend {
    func legend(legend: String, array: [String])
}

class LegendViewController: UIViewController, UITextViewDelegate {
    var userJson = [JSON]()
    @IBOutlet weak var textView: UITextView!
    var delegate: NewLegend!
    var legend: String!
    var arrayId = [["id":"","nickname":""]]
    var id = [String]()
    override func viewDidLoad() {
        super.viewDidLoad()
        textView.text = legend
        textView.becomeFirstResponder()
        arrayId.removeAll()
        loadUser()
        if (legend) != nil {
            self.formatText()
        }
    }

    @IBAction func stop(_ sender: Any) {
        navigationController?.popViewController(animated: true)
//        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func send(_ sender: UIBarButtonItem) {
        delegate.legend(legend: textView.text, array: id)
        navigationController?.popViewController(animated: true)
    }
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == " ",let lastWord = textView.text.components(separatedBy: " ").last, lastWord.hasPrefix("@"), let lastWordRange = (textView.text as NSString?)?.range(of: lastWord){
            if self.search(in: lastWord), searchDuplicate(this: lastWord) == 1  {
                let attributes = [NSForegroundColorAttributeName: UIColor.blue, NSFontAttributeName: self.textView.font!] as [String : Any]
                let attributedString = NSMutableAttributedString(string: lastWord, attributes: attributes)
                textView.textStorage.replaceCharacters(in:lastWordRange, with:attributedString)
                
            }else{
                print(searchDuplicate(this: lastWord))
                if searchDuplicate(this: lastWord) > 1 {
                    let lastWordRange = (textView.text as NSString?)?.range(of: lastWord, options: [.backwards])
                    //textView.text.removeSubrange(Range(uncheckedBounds: (lower: textView.text.index(textView.text.endIndex, offsetBy: -lastWord.characters.count ), upper: textView.text.endIndex)))
                   // textView.text.replacingCharacters(in: Range(uncheckedBounds: (lower: textView.text.index(textView.text.endIndex, offsetBy: -lastWord.characters.count ), upper: textView.text.endIndex)), with: "")
                    textView.textStorage.replaceCharacters(in: lastWordRange!, with: "")
                }else {
                    let realLW = lastWord.replacingOccurrences(of: "@", with: "")
                    textView.textStorage.replaceCharacters(in:lastWordRange, with:realLW)
                }
            }
        }
        return true
        
    }
    /*func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        if text == " " {
            let newText = removeDuplicates(text: textView.attributedText.string ?? "")
            let attributes = [NSForegroundColorAttributeName: UIColor.blue, NSFontAttributeName: self.textView.font!] as [String : Any]
            let attributedString = NSMutableAttributedString(string: newText, attributes: attributes)
            textView.attributedText = attributedString
        }
        return true
    }
    
    func removeDuplicates(text: String) -> String {
        let words = text.components(separatedBy: " ")
        let filtered = words.filter { $0.first == "@" }
        return Array(Set(filtered)).joined()
    }*/
    func loadUser(){
        let endpoint = "/user"
        Api.instance.get(endpoint).then {JSON in
           // print("the Json in response promise \(JSON)")
          self.userJson =  JSON["users"].arrayValue
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
                id.append(userJson[i]["id"].stringValue)
                let localA = ["id": userJson[i]["id"].stringValue, "nickname":userJson[i]["nickname"].stringValue]
                arrayId.append(localA)
                //arrayId.insert(<#T##newElement: Dictionary<String, String>##Dictionary<String, String>#>, at: <#T##Int#>)
                return true
            }
        }
        print(false)
        return false
    }
    func searchDuplicate(this word: String) -> Int{
        var i = 0
        let words = textView.text.components(separatedBy: " ")
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
    }
}
