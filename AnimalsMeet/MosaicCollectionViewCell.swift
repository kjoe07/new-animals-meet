//
//  MosaicCollectionViewCell.swift
//  AnimalsMeet
//
//  Created by gwendal lasson on 06/06/2017.
//  Copyright © 2017 AnimalsMeet. All rights reserved.
//

import UIKit
import Kingfisher

class MosaicCollectionViewCell: UICollectionViewCell {
   @IBOutlet weak var image: UIImageView!
   var currentOperation: RetrieveImageTask?
   
   func set(url: URL) {
      currentOperation = self.image.kf.setImage(with: url)
   }
   
   override func prepareForReuse() {
      super.prepareForReuse()
      currentOperation?.cancel()
      image.image = nil
   }
}
