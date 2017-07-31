//
//  AnimalResultCollectionViewCell.swift
//  AnimalsMeet
//
//  Created by Adrien Morel on 21/12/2016.
//  Copyright © 2016 AnimalsMeet. All rights reserved.
//

import UIKit

class AnimalResultCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var animalPic: UIImageView!
    @IBOutlet weak var stackview: StackViewVerticalCut!
    
    @IBOutlet weak var addFriendButton: UIButton!
    
    
    var likeStatus = true
    var userId: Int!
    var searchResultViewController: SearchResultsViewController?
    var isHeat = false
    var gradientAreSet = false
    var heatView: UIImageView?
    
    @IBAction func chat(_ sender: Any) {
        searchResultViewController?.chat(withUser: userId)
    }
    
    @IBAction func addFriend(_ sender: Any) {

    }
    
    @IBOutlet weak var petNameAge: UILabel!
    @IBOutlet weak var distance: UILabel!
    
    var addedGradients = false
    
//    @IBOutlet weak var petAgeName: UILabel!
  //  @IBOutlet weak var petRace: UILabel!
    
    override func layoutSubviews() {
        
        super.layoutSubviews()
        setGradients()
        gradientAreSet = true
        setDropShadow()
        
        if isHeat {
            heatView = animalPic.markUIWithHeat()
        } else {
            heatView?.removeFromSuperview()
        }
    }
    
    func setDropShadow() {
        
        let shadowPath = UIBezierPath(rect: bounds)
        layer.masksToBounds = false
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0.5, height: 0.5)
        layer.shadowOpacity = 0.2
        layer.shadowPath = shadowPath.cgPath
    }
    
    let bottomGradient = CAGradientLayer()
    let    topGradient = CAGradientLayer()
    
    func setGradients() {
        
        bottomGradient.removeFromSuperlayer()
        topGradient.removeFromSuperlayer()

        let gradientHeight = frame.height / 4
        
        bottomGradient.frame =
            CGRect(x: animalPic.frame.minX, y: animalPic.frame.maxY - gradientHeight, width: animalPic.frame.width, height: gradientHeight)
        topGradient.frame =
            CGRect(x: animalPic.frame.minX, y: animalPic.frame.minY, width: animalPic.frame.width, height: gradientHeight)
        
        bottomGradient.colors = [UIColor.clear, UIColor.black.cgColor]
        topGradient.colors = [UIColor.black.cgColor, UIColor.clear]
        
        bottomGradient.opacity = 0.7
        topGradient.opacity = 0.7
        
        bottomGradient.zPosition = 1
        topGradient.zPosition = 1
        
        animalPic.setNeedsLayout()
        
        animalPic.layer.insertSublayer(bottomGradient, at: 0)
        animalPic.layer.insertSublayer(   topGradient, at: 0)
    }
}
