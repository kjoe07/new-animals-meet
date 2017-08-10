//
//  hideKeyboardOnTouchView.swift
//  Alveokustic
//
//  Created by Adrien Morel on 12/12/2016.
//  Copyright © 2016 Gwendal Lasson. All rights reserved.
//

import UIKit

class HideKeyboardOnTouchView: UIView {
    
    override func awakeFromNib() {
        
        super.awakeFromNib()

        let tapper = UITapGestureRecognizer(target: self, action:#selector(endEditing))
        tapper.cancelsTouchesInView = false
        addGestureRecognizer(tapper)
    }
}
