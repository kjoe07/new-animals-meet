//
//  sectionTableViewCell.swift
//  AnimalsMeet
//
//  Created by Yoel JImenez del Valle on 26/12/17.
//  Copyright © 2017 AnimalsMeet. All rights reserved.
//

import UIKit

class sectionTableViewCell: UITableViewCell {
	@IBOutlet weak var segmentedControl: UISegmentedControl!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
