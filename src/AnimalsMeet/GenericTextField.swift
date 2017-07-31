//
//  GenericTextField.swift
//  AnimalsMeet
//
//  Created by Bastien Ravalet on 16/11/2016.
//  Copyright © 2016 AnimalsMeet. All rights reserved.
//

import Foundation
import UIKit

class GenericTextField : UITextField, UITextFieldDelegate {
    override func awakeFromNib() {
        self.delegate = self
        
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.resignFirstResponder()
        return true
    }
}

class NumericTextField: UITextField {
    let numericKbdToolbar = UIToolbar()
    
    // MARK: Initilization
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.initialize()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.initialize()
    }
    
    // Sets up the input accessory view with a Done button that closes the keyboard
    func initialize()
    {
        self.keyboardType = UIKeyboardType.numberPad
        
        numericKbdToolbar.barStyle = UIBarStyle.default
        let space = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        let callback = #selector(NumericTextField.finishedEditing)
        let donebutton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.done, target: self, action: callback)
        numericKbdToolbar.setItems([space, donebutton], animated: false)
        numericKbdToolbar.sizeToFit()
        self.inputAccessoryView = numericKbdToolbar
    }
    
    // MARK: On Finished Editing Function
    func finishedEditing()
    {
        self.resignFirstResponder()
    }
}
