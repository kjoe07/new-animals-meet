//
//  StackViewVerticalCut.swift
//  AnimalsMeet
//
//  Created by Adrien Morel on 21/12/2016.
//  Copyright © 2016 AnimalsMeet. All rights reserved.
//

import UIKit

class StackViewVerticalCut: UIStackView {
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setupMidBar()
    }
    
    func setupMidBar() {
        let vertical = CALayer()
        
        vertical.backgroundColor = UIColor.gray.cgColor
        vertical.opacity = 0.3
        vertical.frame = CGRect(x: self.frame.midX, y: 0, width: 1, height: self.frame.height)
        self.layer.addSublayer(vertical)
    }
}
