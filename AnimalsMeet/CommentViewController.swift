//
//  CommentViewController.swift
//  AnimalsMeet
//
//  Created by Adrien morel on 02/05/2017.
//  Copyright © 2017 AnimalsMeet. All rights reserved.
//

import UIKit
import SearchTextField
import CZPicker
import SwiftyJSON
class CommentViewController: UIViewController, UITextFieldDelegate, CZPickerViewDelegate, CZPickerViewDataSource, UITextViewDelegate {
    @IBOutlet weak var writeAComment: UIView!
    @IBOutlet weak var tableViewContainer: UIView!
    
    @IBOutlet weak var sendButton: UIButton!
    let commentTableViewController = CommentTableViewController()
    var media: MediaModel!
    
    var users = ["User1","User2","User3"]
    var userMode = false
    let picker = CZPickerView(headerTitle: "Friends", cancelButtonTitle: "Cancel", confirmButtonTitle: "Confirm")
    @IBOutlet weak var commentInput: UITextView! //SearchTextField!
    var userJson = [JSON]()
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Commentaires"
        addChildViewController(commentTableViewController)
        tableViewContainer.addSubview(commentTableViewController.view)
        commentTableViewController.view.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        commentInput.delegate = self
        commentInput.keyboardType = .emailAddress
        commentInput.becomeFirstResponder()
        
       // commentInput.addTarget(self, action: #selector(self.textEditingChanged(_:)), for: .editingChanged)
        self.sendButton.alpha = 0
        loadUser()
        
        picker?.delegate = self
        picker?.dataSource = self
        picker?.needFooterView = false
        
    }
    func textViewDidChange(_ textView: UITextView) {
        if commentInput.text?.isEmpty != false {
            self.sendButton.alpha = 0
        }
        else {
            self.sendButton.alpha = 1
        }
    }
    func textViewDidChangeSelection(_ textView: UITextView) {
        if let lastWord = textView.text.components(separatedBy: " ").last, lastWord.hasPrefix("@"), let lastWordRange = (textView.text as NSString?)?.range(of: lastWord){
            textView.resignFirstResponder()
            picker?.show()
        }
    }
    /*func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let lastWord = commentInput.text?.components(separatedBy: " ").last, lastWord.hasPrefix("@"), let lastWordRange = (commentInput.text as NSString?)?.range(of: lastWord){
            /*if self.search(in: lastWord), searchDuplicate(this: lastWord) == 1  {
                let attributes = [NSForegroundColorAttributeName: UIColor.blue, NSFontAttributeName: self.textView.font!] as [String : Any]
                let attributedString = NSMutableAttributedString(string: lastWord, attributes: attributes)
                //textView.textStorage.replaceCharacters(in:lastWordRange, with:attributedString)
                
            }else{
                print(searchDuplicate(this: lastWord))
                if searchDuplicate(this: lastWord) > 1 {
                    let lastWordRange = (textView.text as NSString?)?.range(of: lastWord, options: [.backwards])
                    //textView.text.removeSubrange(Range(uncheckedBounds: (lower: textView.text.index(textView.text.endIndex, offsetBy: -lastWord.characters.count ), upper: textView.text.endIndex)))
                    // textView.text.replacingCharacters(in: Range(uncheckedBounds: (lower: textView.text.index(textView.text.endIndex, offsetBy: -lastWord.characters.count ), upper: textView.text.endIndex)), with: "")
                  //  textView.textStorage.replaceCharacters(in: lastWordRange!, with: "")
                }else {
                    let realLW = lastWord.replacingOccurrences(of: "@", with: "")
                    textView.textStorage.replaceCharacters(in:lastWordRange, with:realLW)
                }
            }*/
             let attributedString = NSMutableAttributedString()
             let words = commentInput.text?.components(separatedBy: " ")
             for i in 0..<(words?.count)! {
                if (words?[i].hasPrefix("@"))!{
                    print("has it")
                    attributedString.bold((words?[i])!+" ")
                }else{
                    attributedString.normal((words?[i])!+" ")
                }
             //let myAddedString = attributedString(string: words[i], attributes: nil)          //  self.commentInput.attributedText
             }
             //
             self.commentInput.attributedText = attributedString/**/
        }
        return true
    }*/
    /*func textEditingChanged(_ sender: Any) {
        if commentInput.text?.isEmpty != false {
            self.sendButton.alpha = 0
        }
        else {
            self.sendButton.alpha = 1
        }
        if let b = commentInput.text?.hasSuffix(" @"), b {
            userMode = true
            //picker.
            picker?.show()
            
        }
        if userMode {
            commentInput.filterStrings(users)
        }
    }*/
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        sendComment(self)
        self.commentInput.text = ""
        return true
    }
    
    @IBAction func sendComment(_ sender: Any) {
        guard !commentInput.text!.isEmpty else {
            return
        }
        
        let comment = commentInput.text!
        let commentModel = CommentModel()
        commentModel.author = App.instance.userModel
        commentModel.text = comment
        commentModel.likeCount = 0
        commentTableViewController.theData.append(commentModel)
        commentTableViewController.tableView.reloadData()
        commentInput.text = ""
        //self.textEditingChanged(self)
        
        commentInput.resignFirstResponder()
        media.comment(content: comment)
            .then { _ in
                self.commentTableViewController.shouldRefresh()
            }
            .catch { _ in
                self.commentInput.text = comment
        }
    }
    
    public static func newInstance(_ media: MediaModel) -> CommentViewController {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "CommentVC") as! CommentViewController
        vc.media = media
        return vc
    }
    func loadUser(){
        let endpoint = "/user/\(App.instance.userModel.id!)/friends" //"/user" //
        Api.instance.get(endpoint).then {JSON in
            //print("the Json in response promise \(JSON)")
            self.userJson =  JSON["friends"].arrayValue
            }.always {
                self.picker?.reloadData()
        }
    }

    func numberOfRows(in pickerView: CZPickerView!) -> Int {
        print(userJson.count)
        return userJson.count
    }
    
    func czpickerView(_ pickerView: CZPickerView!, titleForRow row: Int) -> String! {
        return userJson[row]["nickname"].stringValue
    }
    
    func czpickerView(_ pickerView: CZPickerView!, didConfirmWithItemAtRow row: Int){
       /* print("aqui es adonde")
        print("el valor del row\(userJson[row].arrayValue)")
        self.commentInput.text?.append(userJson[row]["nickname"].stringValue)
        /*var attributedString = NSMutableAttributedString()
        /*let formattedString = NSMutableAttributedString()
        formattedString
            .bold("Bold Text")
            .normal(" Normal Text ")
            .bold("Bold Text")
        
        let lbl = UILabel()
        lbl.attributedText = formattedString*/
        let words = commentInput.text?.components(separatedBy: " ")
        for i in 0..<(words?.count)! {
            if (words?[i].hasPrefix("@"))!{
                print("has it")
                attributedString.bold(userJson[row]["nickname"].stringValue + /*(words?[i])!*/" ")
            }else{
                attributedString.normal((words?[i])!+" ")
            }
            //let myAddedString = attributedString(string: words[i], attributes: nil)          //  self.commentInput.attributedText
        }
        //
        self.commentInput.attributedText = attributedString*/
        self.navigationController?.setNavigationBarHidden(false, animated: true)*/
        print("aqui es adonde")
        print("el valor del row\(userJson[row].arrayValue)")
        //print(fruits[row])
        commentInput.text.append(userJson[row]["nickname"].stringValue)
        if let lastWord = commentInput.text.components(separatedBy: " ").last, lastWord.hasPrefix("@"), let lastWordRange = (commentInput.text as NSString?)?.range(of: lastWord, options: .backwards){
            let attributes = [NSForegroundColorAttributeName: UIColor.blue, NSFontAttributeName: self.commentInput.font!] as [String : Any]
            let attributedString = NSMutableAttributedString(string: "@"+userJson[row]["nickname"].stringValue, attributes: attributes)
            
            commentInput.textStorage.replaceCharacters(in: lastWordRange, with: attributedString)
           _ = self.search(in: userJson[row]["nickname"].stringValue)
        }
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    func czpickerViewWillDismiss(_ pickerView: CZPickerView!) {
        commentInput.becomeFirstResponder()
    }
    func czpickerViewDidClickCancelButton(_ pickerView: CZPickerView!) {
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    @nonobjc func czpickerView(_ pickerView: CZPickerView!, didConfirmWithItemsAtRows rows: [AnyObject]!) {
        
       /* for row in rows {
            if let row = row as? Int {
                // print(fruits[row])
            }
        }*/
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
                //id.append(userJson[i]["id"].stringValue)
                let localA = ["id": userJson[i]["id"].stringValue, "nickname":userJson[i]["nickname"].stringValue]
                //arrayId.append(localA)
                //arrayId.insert(<#T##newElement: Dictionary<String, String>##Dictionary<String, String>#>, at: <#T##Int#>)
                return true
            }
        }
        print(false)
        return false
    }
    func addBoldText(fullString: NSString, boldPartsOfString: Array<NSString>, font: UIFont!, boldFont: UIFont!) -> NSAttributedString {
        let nonBoldFontAttribute = [NSFontAttributeName:commentInput.font]
        let boldFontAttribute = [NSFontAttributeName:commentInput.font,NSForegroundColorAttributeName: UIColor.blue] as [String : Any]
        let boldString = NSMutableAttributedString(string: fullString as String, attributes:nonBoldFontAttribute)
        for i in 0 ..< boldPartsOfString.count {
            boldString.addAttributes(boldFontAttribute, range: fullString.range(of: boldPartsOfString[i] as String))
        }
        return boldString
    }
}
extension NSMutableAttributedString {
    @discardableResult func bold(_ text:String) -> NSMutableAttributedString {
        let attrs:[String:AnyObject] = [NSForegroundColorAttributeName: UIColor.blue]
        let boldString = NSMutableAttributedString(string: text, attributes:attrs)
        self.append(boldString)
        return self
    }
    
    @discardableResult func normal(_ text:String)->NSMutableAttributedString {
        let normal =  NSAttributedString(string: text)
        self.append(normal)
        return self
    }
}
extension UIViewController{
    func encode_emoji(_ s: String) -> String {
        let data = s.data(using: .nonLossyASCII, allowLossyConversion: true)!
        return String(data: data, encoding: .utf8)!
    }
    func decode_emoji(_ s: String) -> String? {
        let data = s.data(using: .utf8)!
        return String(data: data, encoding: .nonLossyASCII)
    }
}
