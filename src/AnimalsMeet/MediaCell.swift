//
//  ListPicturesCell.swift
//  AnimalsMeet
//
//  Created by Sacha IFRAH on 04/12/2016.
//  Copyright © 2016 AnimalsMeet. All rights reserved.
//

import Foundation
import PromiseKit
import UIKit
import SwiftyJSON
import FBSDKShareKit
import AFDateHelper
import SwiftDate

class MediaCell: UITableViewCell {
    
    @IBOutlet var mediaView: UIView!
    @IBOutlet weak var nicknames: UILabel!
    @IBOutlet weak var profilePic: UIImageView!
    
    @IBOutlet weak var likeBtn: UIButton!
    @IBOutlet weak var likeLbl: UILabel!
    @IBOutlet weak var postTime: UILabel!
    @IBOutlet weak var legend: UITextView!
    
    var media: MediaModel!
    var goToProfile: (() -> ())!
    var goToComments: (() -> ())!
    
    func updateLikeCount() {
        likeLbl.text = "\(media.likeCount) J'aime"
    }
    
    func setMedia(_ media: MediaModel) {
        
        for v in mediaView.subviews {
            v.removeFromSuperview()
        }
        self.media = media
        
        let title = NSMutableAttributedString()
        title.append(media.animal.name!, withFont: .boldSystemFont(ofSize: 13))
        if media.author != nil {
            let nickname = media.author.nickname!
            title.append(" @\(nickname)")
        }
        nicknames.attributedText = title
        updateLikeCount()
        legend.isHidden = media.description == nil
        legend.textContainerInset = UIEdgeInsets.zero
        legend.textContainer.lineFragmentPadding = 0;
        legend.text = media.description ?? "hello world"
        postTime.text = try! media.updatedAt.colloquialSinceNow().colloquial
        profilePic.kf.setImage(with: media.animal.profilePicUrl)
        
        likeBtn.setImage(media.isLiked ? #imageLiteral(resourceName: "heart red") : #imageLiteral(resourceName: "heart"), for: .normal)
        
        if media.isText {
            let textView = UITextView()
            textView.text = media.contentText
            textView.isEditable = false
            textView.isScrollEnabled = false
            textView.font = UIFont.systemFont(ofSize: 18)
            mediaView.addSubview(textView)
            textView.snp.makeConstraints { make in
                make.edges.equalToSuperview().inset(UIEdgeInsetsMake(0, 10, 0, 10))
            }
        } else {
            let image = UIImageView()
            mediaView.addSubview(image)
            image.kf.setImage(with: media.url)

            let height = CGFloat(media.height)
            let width = CGFloat(media.width)
            let scaleFactor = UIScreen.main.scale
            let screenWidth = CGFloat(UIScreen.main.bounds.width)
            let imageHeight = (height / (width / (screenWidth * scaleFactor))) / scaleFactor
            
            image.snp.makeConstraints { make in
                make.edges.equalToSuperview()
                make.height.equalTo(imageHeight)
            }
            image.contentMode = .scaleAspectFill
        }
    }
    
    @IBAction func goToProfile(_ sender: Any) {
        goToProfile()
    }
    
    @IBAction func reportPicture(_ sender: Any) {
        
        let optionMenu = UIAlertController(title: nil, message: "Que voulez vous faire ?", preferredStyle: .actionSheet)
        
        var title = ""
        if media.animal.isMine() {
            if media.isText {
                title = "Supprimer ce post"
            } else {
                title = "Supprimer cette photo"
            }
        } else {
            if media.isText {
                title = "Signaler ce post"
            } else {
                title = "Signaler cette photo"
            }
        }
        
        let action = UIAlertAction(title: title, style: .destructive, handler: {
            (alert: UIAlertAction!) -> Void in
            if self.media.animal.isMine() {
                self.media.callForDelete()
                    .then { _ -> Promise<()> in
                        (self.viewController() as! EasyTableViewController<MediaModel,MediaCell>).shouldRefresh()
                    }
                    .catch(execute: App.showRequestFailure)
            } else {
                self.showAlert()
            }
        })
        
        let cancelAction = UIAlertAction(title: "Annuler", style: .cancel, handler: {
            (alert: UIAlertAction!) -> Void in
            print("Cancelled")
        })
        
        optionMenu.addAction(action)
        optionMenu.addAction(cancelAction)
        
        viewController()!.present(optionMenu, animated: true, completion: nil)
    }
    
    func showAlert() {
        alert.showAlertWarning(title: "Merci", subTitle: "Nous allons examiner votre demande")
    }
    
    @IBAction func shareNow(_ sender: Any) {
        
        if media.isText {
            
        } else {
            let image = (mediaView.subviews[0] as! UIImageView).image
            
            // set up activity view controller
            let imageToShare = [ image! ]
            let activityViewController = UIActivityViewController(activityItems: imageToShare, applicationActivities: nil)
            activityViewController.popoverPresentationController?.sourceView = self.viewController()?.view // so that iPads won't crash
            
            // exclude some activity types from the list (optional)
            activityViewController.excludedActivityTypes = [ UIActivityType.airDrop]
            
            // present the view controller
            self.viewController()?.present(activityViewController, animated: true, completion: nil)
        }
    }
    
    @IBAction func doLike(_ sender: UIButton) {
        
        UIView.transition(with: sender, duration: 0.2, options: .transitionCrossDissolve, animations: {
            
            if self.media.isLiked {
                self.media.isLiked = false
                self.media.likeCount -= 1
                _ = self.media.callForUnlike().then { _ -> Void in self.updateLikeCount() }
                sender.setImage(#imageLiteral(resourceName: "heart"), for: .normal)
            } else {
                self.media.isLiked = true
                self.media.likeCount += 1
                _ = self.media.callForLike(fromAnimal: App.instance.getSelectedAnimal().id).then { _ -> Void in self.updateLikeCount() }
                sender.setImage(#imageLiteral(resourceName: "heart red"), for: .normal)
            }
        }, completion: nil)
    }
    
    @IBAction func showComments(_ sender: Any) {
        goToComments?()
    }
}
