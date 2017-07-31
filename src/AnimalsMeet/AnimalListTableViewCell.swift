//
//  AnimalListTableViewCell.swift
//  AnimalsMeet
//
//  Created by Adrien morel on 19/05/2017.
//  Copyright © 2017 AnimalsMeet. All rights reserved.
//

import UIKit
import Sensitive

class AnimalListTableViewCell: UITableViewCell {

    @IBOutlet weak var animalPic: UIImageView!
    @IBOutlet weak var animalName: UILabel!
    @IBOutlet weak var settings: UIButton!
    
    func configure(picUrl: URL, name: String) {
        animalPic.clipsToBounds = true
        animalPic.layer.cornerRadius = (80 - 16 * 2) / 2
        animalPic.kf.setImage(with: picUrl)
        animalName.text = name
    }
    
    func setEditable(_ value: Bool) {
        settings.isHidden = !value
    }
}
