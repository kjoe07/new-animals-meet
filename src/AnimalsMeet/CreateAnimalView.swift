//
//  createAnimalView.swift
//  AnimalsMeet
//
//  Created by Adrien morel on 23/05/2017.
//  Copyright © 2017 AnimalsMeet. All rights reserved.
//

import UIKit

class CreateAnimalView: UIView {
    
    var callback: (() -> ())!
    
    @IBAction func create(_ sender: Any) {
        callback()
    }
}
