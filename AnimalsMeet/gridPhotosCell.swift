//
//  gridPhotosCell.swift
//  AnimalsMeet
//
//  Created by Yoel JImenez del Valle on 20/12/17.
//  Copyright © 2017 AnimalsMeet. All rights reserved.
//

import UIKit

class gridPhotosCell: UITableViewCell {
	@IBOutlet weak var imagesCollection: UICollectionView!

    override func awakeFromNib() {
        super.awakeFromNib()
		imagesCollection.register(MosaicCollectionViewCell.self, forCellWithReuseIdentifier: "MosaicCollectionViewCell")
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
