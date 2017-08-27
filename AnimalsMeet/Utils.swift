//
//  Utils.swift
//  AnimalsMeet
//
//  Created by gwendal lasson on 09/06/2017.
//  Copyright © 2017 AnimalsMeet. All rights reserved.
//

import UIKit
import Lightbox
import FontAwesomeKit

func presentFullScreen(image: UIImage, onVC VC: UIViewController) {
   let controller = LightboxController(images: [LightboxImage(image: image)])
   VC.present(controller, animated: true, completion: nil)
}

func presentFullScreen(imageURL: URL, onVC VC: UIViewController, media: MediaModel) {
   let controller = CustomLightBoxController(images: [LightboxImage(imageURL: imageURL)])
   
   let view = UIView()
   view.backgroundColor = .clear
//   view.backgroundColor = .red
   controller.footerView.addSubview(view)
   view.frame = CGRect(x: 0, y: 0, width: controller.footerView.width, height: 30)
   view.autoresizingMask = [.flexibleWidth, .flexibleBottomMargin]
   
   
   let heartIcon = FAKIonIcons.iosHeartOutlineIcon(withSize: 20)
   heartIcon?.addAttribute(NSForegroundColorAttributeName, value: UIColor.white)
   
   let filledHeartIcon = FAKIonIcons.iosHeartIcon(withSize: 20)
   filledHeartIcon?.addAttribute(NSForegroundColorAttributeName, value: UIColor.white)
//   let heartImage = heartIcon?.image(with: CGSize(width: 24, height: 24))
   
   let heartButton = UIButton(type: .system)
   
   if media.isLiked {
      heartButton.setAttributedTitle(filledHeartIcon?.attributedString(), for: .normal)
   }
   else {
      heartButton.setAttributedTitle(heartIcon?.attributedString(), for: .normal)
   }
   
   heartButton.sizeToFit()
   heartButton.translatesAutoresizingMaskIntoConstraints = false
   
   heartButton.onTap { (recognizer) in
//      UIView.transition(with: heartButton, duration: 0.2, options: .transitionCrossDissolve, animations: {
      
         if media.isLiked {
            media.likeCount -= 1
            media.isLiked = false
            
            _ = media.callForUnlike().then { _ -> Void in  }
//            heartButton.setImage(#imageLiteral(resourceName: "heart"), for: .normal)
            heartButton.setAttributedTitle(heartIcon?.attributedString(), for: .normal)
         } else {
            media.likeCount += 1
            media.isLiked = true
            
            _ = media.callForLike(fromAnimal: App.instance.getSelectedAnimal().id).then { _ -> Void in  }
//            heartButton.setImage(#imageLiteral(resourceName: "heart red"), for: .normal)
            heartButton.setAttributedTitle(filledHeartIcon?.attributedString(), for: .normal)
         }
//      }, completion: nil)
   }
   
   view.addSubview(heartButton)
   heartButton.snp.makeConstraints { (maker) in
      maker.trailing.equalToSuperview().inset(20)
      maker.top.equalToSuperview()
   }
   
   let title = NSMutableAttributedString()
   title.append(media.animal.name!, withFont: .boldSystemFont(ofSize: 13))
   if media.author != nil {
      let nickname = media.author.nickname!
      title.append(" @\(nickname)")
   }
   title.addAttribute(NSForegroundColorAttributeName, value: UIColor.white, range: NSRange.init(location: 0, length: title.length))
   
   let showProfileButton = UIButton(type: .system)
   showProfileButton.setAttributedTitle(title, for: .normal)
   
   
   showProfileButton.onClick {
      let profileVC = AnimalVC.newInstance(media.animal)
      
      let backButton = UIBarButtonItem(title: "Close", style: .done, target: controller, action: #selector(controller.dismissItem(_:)))
      profileVC.navigationItem.rightBarButtonItem = backButton
      
//      controller.navigationController?.pushViewController(profileVC, animated: true)
      let navigationController = UINavigationController(rootViewController: profileVC)
      
      controller.present(navigationController, animated: true, completion: nil)
   }
   
   view.addSubview(showProfileButton)
   showProfileButton.snp.makeConstraints { (maker) in
      maker.trailing.equalToSuperview().inset(60)
      maker.top.equalToSuperview()
      maker.width.equalTo(120)
   }
   
   showProfileButton.invalidateIntrinsicContentSize()
   showProfileButton.sizeToFit()
   
   VC.present(controller, animated: true, completion: nil)
}

class CustomLightBoxController: LightboxController {
   func dismissItem(_ sender: Any) {
      self.dismiss(animated: true, completion: nil)
   }
   
   override func didMove(toParentViewController parent: UIViewController?) {
      if parent != nil {
         (self.tabBarController as! AnimalTabBarController).centerButton.isHidden = true
      }
      else {
         (self.tabBarController as! AnimalTabBarController).centerButton.isHidden = false
      }
   }
   
   override func viewDidLoad() {
      super.viewDidLoad()
      
   }
   
   override func viewWillAppear(_ animated: Bool) {
      super.viewWillAppear(animated)
      self.navigationController?.setNavigationBarHidden(true, animated: true)
   }

   override func viewWillDisappear(_ animated: Bool) {
      super.viewWillDisappear(animated)
      self.navigationController?.setNavigationBarHidden(false, animated: true)
   }
}
