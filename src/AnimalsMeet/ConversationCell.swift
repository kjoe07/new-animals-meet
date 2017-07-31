//
//  ConversationCell.swift
//  AnimalsMeet
//
//  Created by Adrien morel on 28/05/2017.
//  Copyright © 2017 AnimalsMeet. All rights reserved.
//

import UIKit

class ConversationCell: UITableViewCell {
    
    @IBOutlet weak var profilePic: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var lastMsg: UILabel!
    @IBOutlet weak var lastMsgTime: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        UIKitViewUtils.setCornerRadius(sender: profilePic, radius: profilePic.bounds.width / 2)
    }
}
