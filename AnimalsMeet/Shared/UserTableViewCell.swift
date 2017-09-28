//
//  UserTableViewCell.swift
//  AnimalsMeet
//
//  Created by Reynaldo Aguilar on 8/27/17.
//  Copyright © 2017 AnimalsMeet. All rights reserved.
//

import UIKit
import Kingfisher

class UserTableViewCell: UITableViewCell {
   static let identifier = "UserTableViewCell"
   @IBOutlet weak var avatarView: UIImageView!
   @IBOutlet weak var nameLabel: UILabel!
   @IBOutlet weak var nicknameLabel: UILabel!
   
   var currentOperation: RetrieveImageTask?
   
   var item: UserModel? {
      didSet {
         guard let item = self.item else { return }
         
         currentOperation = avatarView.kf.setImage(with: item.image)
         nameLabel.text = item.name
         nicknameLabel.text = item.nickname
      }
   }
   
   override func prepareForReuse() {
      super.prepareForReuse()
      currentOperation?.cancel()
      avatarView.image = nil
   }
   
   override func awakeFromNib() {
      super.awakeFromNib()
      // Initialization code
      avatarView.rounded()
   }
   
   override func setSelected(_ selected: Bool, animated: Bool) {
      super.setSelected(selected, animated: animated)
      
      // Configure the view for the selected state
   }
   
}
