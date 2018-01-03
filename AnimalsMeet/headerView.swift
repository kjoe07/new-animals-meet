//
//  headerView.swift
//  AnimalsMeet
//
//  Created by Yoel JImenez del Valle on 8/12/17.
//  Copyright © 2017 AnimalsMeet. All rights reserved.
//

import UIKit
class headerView: UIView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    @IBOutlet weak var iconHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var nickname: UILabel!
    @IBOutlet var animal_name_age: UILabel!
    @IBOutlet var animal_breed: UILabel!
    @IBOutlet var animal_localisation: UILabel!
    @IBOutlet var animal_state_icon_1: UIImageView!
    @IBOutlet var animal_state_icon_2: UIImageView!
    @IBOutlet var animal_state_icon_3: UIImageView!
    @IBOutlet var animal_state_icon_4: UIImageView!
    @IBOutlet var animal_total_like: UILabel!
    @IBOutlet var customNavBar: UIView!
    @IBOutlet weak var animalProfilePic: UIImageView!
    @IBOutlet weak var userProfilePic: UIImageView!
    @IBOutlet weak var myAccount: UIButton!
    @IBOutlet weak var animalsButton: UIButton!
    @IBOutlet weak var sendMessageButton: UIButton!
    @IBOutlet weak var addFriendButton: UIButton!
    @IBOutlet weak var plume: UIButton!
    @IBOutlet weak var followersCount: UILabel!
    @IBOutlet weak var followingCount: UILabel!
    @IBOutlet weak var likeCount: UILabel!
	@IBOutlet weak var FriendsButton: UIButton!
	@IBOutlet weak var suivis: UILabel!
	//@IBOutlet weak var animalButtonConstraintRight: NSLayoutConstraint!
    let maxHeight: CGFloat = 120//80
    let minHeight: CGFloat = 90//50
    
    override func awakeFromNib() {
        super.awakeFromNib()
        //self.iconHeightConstraint.constant = maxHeight
		
    }
    
    func animator(t: CGFloat) {
        //    print(t)
        
        if t < 0 {
            iconHeightConstraint.constant = maxHeight
            return
        }
        
        let height = max(maxHeight - (maxHeight - minHeight) * t, minHeight)
        
        //iconHeightConstraint.constant = height
    }
    
    /*override func sizeThatFits(_ size: CGSize) -> CGSize {
       // descriptionLabel.sizeToFit()
        //let bottomFrame = descriptionLabel.frame
        let iSize = descriptionLabel.systemLayoutSizeFitting(UILayoutFittingCompressedSize)
        /let resultSize = CGSize.init(width: size.width, height: bottomFrame.origin.y + iSize.height)
        return resultSize
    }*/

}
