//
//  LegendViewController.swift
//  AnimalsMeet
//
//  Created by Marilyn on 9/26/17.
//  Copyright © 2017 AnimalsMeet. All rights reserved.
//

import UIKit

protocol NewLegend {
    func legend(legend: String)
}

class LegendViewController: UIViewController, UITextViewDelegate {

    @IBOutlet weak var textView: UITextView!
    var delegate: NewLegend!
    var legend: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textView.text = legend
        textView.becomeFirstResponder()
    }

    @IBAction func stop(_ sender: Any) {
        navigationController?.popViewController(animated: true)
//        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func send(_ sender: UIBarButtonItem) {
        delegate.legend(legend: textView.text)
        navigationController?.popViewController(animated: true)
    }
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == " ",let lastWord = textView.text.components(separatedBy: " ").last, lastWord.hasPrefix("@"), let lastWordRange = (textView.text as NSString?)?.range(of: lastWord){
            let attributes = [NSForegroundColorAttributeName: UIColor.blue, NSFontAttributeName: self.textView.font!] as [String : Any]
            let attributedString = NSMutableAttributedString(string: lastWord, attributes: attributes)
            textView.textStorage.replaceCharacters(in:lastWordRange, with:attributedString)
        }
        return true
    }
}
