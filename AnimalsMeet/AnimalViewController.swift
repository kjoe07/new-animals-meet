//
//  myprofil.swift
//  AnimalsMeet
//
//  Created by Sacha IFRAH on 31/10/2016.
//  Copyright © 2016 AnimalsMeet. All rights reserved.
//
import Foundation
import UIKit
import Kingfisher
import SwiftyJSON
import Sensitive
import ImagePicker
import TOCropViewController
import PromiseKit
import SnapKit
import ARSLineProgress
import Fusuma
import Material

class AnimalVC: UIViewController, UIGestureRecognizerDelegate, FusumaDelegate, PageTabBarControllerDelegate {
   
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
   @IBOutlet weak var topConstraint: NSLayoutConstraint!
   
   var animal: AnimalModel!
   var user: UserModel!
   var shouldHideNavigationBar = true
   let addFriendBgColor = #colorLiteral(red: 0.7540688515, green: 0.7540867925, blue: 0.7540771365, alpha: 1)
   
   let tabFontSize: CGFloat = 18
   
   @IBOutlet weak var feed: UIView!
   
   func makeAndAddVC<T: UIViewController>() -> T {
      let vc = T()
      self.addChildViewController(vc)
      return vc
   }
   
   lazy var photoFeedVC: UserPicsTableViewController = self.makeAndAddVC()
   lazy var postFeedVC: PostFeedVC = self.makeAndAddVC()
   lazy var animalListVC: AnimalListTableViewController = self.makeAndAddVC()
   var tabsVC: ProfileTabViewController!
   
   class func newInstance(_ animal: AnimalModel) -> AnimalVC {
      let animalVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "AnimalVC") as! AnimalVC
      animalVC.animal = animal
      return animalVC
   }
   
   class func newInstance(_ user: UserModel) -> AnimalVC {
      let animalVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "AnimalVC") as! AnimalVC
      animalVC.user = user
      return animalVC
   }
   
   @objc(cropViewController:didCropToImage:withRect:angle:) func cropViewController(_ cropViewController: TOCropViewController, didCropToImage image: UIImage, rect cropRect: CGRect, angle: Int) {
      cropViewController.dismiss(animated: true) { () -> Void in}}
   func cropViewController(_ cropViewController: TOCropViewController, didFinishCancelled cancelled: Bool) {
      cropViewController.dismiss(animated: true) { () -> Void in  }}
   
   func configureNavigationBar() {
      if shouldHideNavigationBar {
         //navigationController!.setNavigationBarHidden(true, animated: false)
      }
      
      navigationController?.navigationBar.isTranslucent = true
   }
   
   override func viewDidLoad() {
      super.viewDidLoad()
      
      if user == nil && animal != nil {
         user = UserModel()
         user.id = animal.ownerId
         if user.isMe {
            user = App.instance.userModel
         }
      }
      
      tabsVC = ProfileTabViewController(viewControllers: [photoFeedVC, postFeedVC])
      tabsVC.delegate = self
      
      self.selectedViewController = photoFeedVC
      
      postFeedVC.pageTabBarItem.title = "Posts"
      postFeedVC.pageTabBarItem.titleColor = .gray
      photoFeedVC.pageTabBarItem.title = "Photos"
      photoFeedVC.pageTabBarItem.titleColor = .gray
      
//      postFeedVC.tableView.isScrollEnabled = false
//      photoFeedVC.tableView.isScrollEnabled = false
      addChildViewController(tabsVC)
      feed.addSubview(tabsVC.view)
      tabsVC.view.frame = feed.bounds
      
      postFeedVC.tableView.showsVerticalScrollIndicator = true
      photoFeedVC.tableView.showsVerticalScrollIndicator = true
      
      myAccount.roundify()
      animalsButton.roundify()
      addFriendButton.roundify()
      addFriendButton.isEnabled = user != nil && user.followers != nil
      sendMessageButton.roundify()
      plume.roundify()
      plume.backgroundColor = #colorLiteral(red: 0.4651720524, green: 0.7858714461, blue: 0.9568093419, alpha: 1)
      
      photoFeedVC.pageTabBarItem.titleLabel!.font = UIFont.boldSystemFont(ofSize: tabFontSize)
      
      /*
       view.onPan(when: .always, handle: { (panGestureRecognizer) in
       self.topConstraint.constant += panGestureRecognizer.translation(in: self.view).y
       }, configure: nil)
       */
   }
   
   override func viewWillAppear(_ animated: Bool) {
      super.viewWillAppear(animated)
      
      var profileLoadPromise: Promise<Void>!
      
      if user == nil {
         setUser(App.instance.userModel!)
      }
      
      if user.isMe {
         let me = App.instance.userModel!
         setUser(me)
         userProfilePic.kf.setImage(with: me.image)
         userProfilePic.onTap { _ in
            if self.user.id == App.instance.userModel.id {
               self.setProfilePic(self)
            }
         }
         
         if me.animals!.count == 0 {
            editAnimal(animal: animal)
            return
         } else {
            if App.instance.userData.selectedAnimal >= me.animals!.count {
               App.instance.userData.selectedAnimal = 0
            }
            
            animal = me.animals![App.instance.userData.selectedAnimal]
            photoFeedVC.animal = animal
            photoFeedVC.unready.ready()
         }
         
         profileLoadPromise = Promise(value: ())
         setUser(user)
      } else {
         profileLoadPromise = Api.instance.get("/user/\(animal.ownerId!)").then { json -> Void in
            self.setUser(UserModel(fromJSON: json["user"]))
            self.userProfilePic.kf.setImage(with: self.user?.image)
         }
         userProfilePic.onTap {_ in
            presentFullScreen(image: self.userProfilePic.image!, onVC: self, media: nil)
         }
      }
      
      setAnimalPicture()
      configureAnimalInfo()
      
      if user.isMe {
         animalListVC.promiseLoadAnimals = Promise(value: user.animals!)
      } else {
         animalListVC.promiseLoadAnimals = profileLoadPromise.then {
            return Api.instance.get("/user/\(self.animal.ownerId!)/animals")
               .then { json -> [AnimalModel] in
                  self.user.animals = json["animals"].arrayValue.map { AnimalModel(fromJSON: $0) }
                  return self.user.animals!
            }
         }
      }
      
      animalListVC.view.frame = feed.bounds
      animalListVC.createAnimal = {
         self.editAnimal(animal: nil)
      }
   }

   
   @IBAction func displayAnimalList(_ sender: Any) {
      navigationController?.pushViewController(animalListVC, animated: true)
   }
   
   @IBAction func follow(_ sender: UIButton) {
      let mode = user.isFriend() ? "unfriend" : "friend"
      if mode == "unfriend" {
         sender.backgroundColor = .white
      } else {
         sender.backgroundColor = addFriendBgColor
      }
      
      Api.instance.post("/user/\(user.id!)/\(mode)")
         .then { _ -> Void in
            if mode == "unfriend" {
               self.user.unfriend()
            } else {
               self.user.friend()
            }
            let message = self.user.isFriend() ? "Vous suivez maintenant cette personne" : "Vous ne suivez plus cette personne"
            alert.showAlertSuccess(title: "Ami", subTitle: message)
         }.catch(execute: App.showRequestFailure)
   }
   
   @IBAction func showFollowers(_ sender: Any) {
      if let users = self.user?.followers, !users.isEmpty {
         let controller = UserListViewController(users: users)
         
         let title = "Abonnés"
         
         controller.title = title
         self.navigationController?.pushViewController(controller, animated: true)
      }
   }
   
   func editAnimal(animal: AnimalModel?) {
      let vc = AnimalConfigurationViewController.newInstance(animal: animal)
      navigationController?.pushViewController(vc, animated: true)
   }
   
   var loadedanimalsfixme = false
   
   @IBOutlet weak var animalButtonConstraintRight: NSLayoutConstraint!
   
   func setUser(_ user: UserModel) {
      self.user = user
      photoFeedVC.user = user
      photoFeedVC.unready.ready()
      animalListVC.user = user
      animalListVC.unready.ready()
      postFeedVC.user = user
      postFeedVC.unready.ready()
      
      nickname.text = "@\(user.nickname!)"
      followingCount.text = "\(user.followingCount!)"
      followersCount.text = "\(user.followersCount!)"
      likeCount.text = "\(user.likeCount!)"
      
      myAccount.isHidden = !user.isMe
      sendMessageButton.isHidden = user.isMe
      addFriendButton.isHidden = user.isMe
      addFriendButton.isEnabled = user.followers != nil
      animal_localisation.isHidden = user.isMe
      if user.isMe {
         animalButtonConstraintRight.constant = -(35 + 8 + 35)
      } else if user.isFriend() {
         addFriendButton.backgroundColor = addFriendBgColor
      }
   }
   
   func reloadAnimal() {
      setAnimalPicture()
      configureAnimalInfo()
   }
   
   func configureAnimalInfo() {
      
      animal_name_age.text = "\(animal.name!), \(animal.year!)"
      animal_breed.text = animal.breedName()
      
      if animal.loof && animal.heat ?? false {
         animal_state_icon_3.image = UIImage(named: "thermometer")
         animal_state_icon_4.image = UIImage(named: "family-tree")
         animal_state_icon_3.isHidden = false
         animal_state_icon_4.isHidden = false
      } else if animal.loof {
         animal_state_icon_3.image = UIImage(named: "family-tree")
         animal_state_icon_3.isHidden = false
         animal_state_icon_4.isHidden = true
      } else if animal.heat ?? false {
         animal_state_icon_3.image = UIImage(named: "thermometer")
         animal_state_icon_3.isHidden = false
         animal_state_icon_4.isHidden = true
      }
      
      if animal.type == "dog" {
         animal_state_icon_1.image = #imageLiteral(resourceName: "husky")
      }
      animal_localisation.text = "\(animal.distance ?? 0) Km"
   }
   
   func setAnimalPicture() {
      
      animalProfilePic.kf.indicatorType = .activity
      animalProfilePic.kf.setImage(with: animal.profilePicUrl,
                                   placeholder: nil,
                                   options: [.transition(.fade(1))],
                                   progressBlock: nil,
                                   completionHandler: nil)
      animalProfilePic.onTap {_ in
         presentFullScreen(image: self.animalProfilePic.image!, onVC: self, media: nil)
      }
      
      animalProfilePic.center.x = userProfilePic.frame.midX + (cos(7 * .pi / 4) * userProfilePic.frame.width / 2 - 2
         - animalProfilePic.frame.width / 2 + (cos(7 * .pi / 4) * animalProfilePic.frame.width / 2))
      animalProfilePic.center.y = userProfilePic.frame.midY + (cos(7 * .pi / 4) * userProfilePic.frame.height / 2 - 2
         - animalProfilePic.frame.height / 2 + (cos(7 * .pi / 4) * animalProfilePic.frame.height / 2))
      animalProfilePic.layer.cornerRadius = animalProfilePic.frame.width / 2
      animalProfilePic.clipsToBounds = true
      
      UIKitViewUtils.setCornerRadius(sender: userProfilePic, radius: userProfilePic.frame.width / 2)
      
      if (animal.sex == .male) {
         UIKitViewUtils.setBorderWidth(sender: userProfilePic, width: 2.0, hexString: "#2978AC")
      } else {
         UIKitViewUtils.setBorderWidth(sender: userProfilePic, width: 2.0, hexString: "#E42772")
      }
   }
   
   @IBAction func talkTo(_ sender: Any) {
      let vc = ConversationViewController()
      vc.conversation = ConversationModel(user: user)
      navigationController!.pushViewController(vc, animated: true)
   }
   
   override func viewWillLayoutSubviews() {
      super.viewWillLayoutSubviews()
      
      configureNavigationBar()
   }
   
   override func viewDidLayoutSubviews() {
      super.viewDidLayoutSubviews()
      
   }
   
   func setProfilePic(_ sender: Any) {
      let fusuma = FusumaViewController()
      fusuma.delegate = self
      fusuma.hasVideo = false
      fusuma.allowMultipleSelection = false
      self.present(fusuma, animated: true, completion: nil)
   }
   
   func fusumaImageSelected(_ image: UIImage, source: FusumaMode) {
      
      let imageData = UIImageJPEGRepresentation(image, 0.3)!
      
      let media = MediaModel()
      media.rawData = imageData.base64EncodedString(options: .lineLength64Characters)
      media.callForCreate().then { json -> Void in
         let createdMedia = MediaModel(fromJSON: json)
         self.user.image = createdMedia.url
         self.userProfilePic.image = image
         alert.showAlertSuccess(title: "Nouvelle image", subTitle: "Votre photo a été enregistré. Elle s'affichera au relancement de l'appli.")
         }.catch(execute: App.showRequestFailure)
   }
   
   func fusumaVideoCompleted(withFileURL fileURL: URL) {}
   func fusumaCameraRollUnauthorized() {}
   func fusumaDismissedWithImage(_ image: UIImage, source: FusumaMode) {}
   func fusumaClosed() {}
   func fusumaWillClosed() {}
   func fusumaMultipleImageSelected(_ images: [UIImage], source: FusumaMode) { }
   
   var selectedViewController: UITableViewController! {
      didSet {
//         let bottomInset = self.selectedViewController.tableView.contentSize.height - feed.bounds.height + 44
//         self.scrollView.contentInset.bottom = max(0, bottomInset)
      }
   }
   
   func pageTabBarController(pageTabBarController: PageTabBarController, didTransitionTo viewController: UIViewController) {
      self.selectedViewController = viewController as? UITableViewController
      
      if viewController == photoFeedVC {
         postFeedVC.pageTabBarItem.titleLabel!.font = UIFont.systemFont(ofSize: tabFontSize)
         photoFeedVC.pageTabBarItem.titleLabel!.font = UIFont.boldSystemFont(ofSize: tabFontSize)
      } else {
         photoFeedVC.pageTabBarItem.titleLabel!.font = UIFont.systemFont(ofSize: tabFontSize)
         postFeedVC.pageTabBarItem.titleLabel!.font = UIFont.boldSystemFont(ofSize: tabFontSize)
      }
   }
   
//   var isDragging = false
//   
//   let scrollOffset: CGFloat = 166
//   
//   var prevOffset: CGFloat = 166
}

extension AnimalVC: UIScrollViewDelegate {
//   func scrollViewDidScroll(_ scrollView: UIScrollView) {
//      print(scrollView.contentOffset.y)
//      let offset = scrollView.contentOffset.y
//      
//      if offset > scrollOffset {
//         isDragging = true
//      }
//      
//      if isDragging {
//         let delta = offset - prevOffset
//         let tableView = self.selectedViewController.tableView!
//         tableView.contentOffset.y += delta
//         tableView.flashScrollIndicators()
//         
//         let translation = max(0, offset - scrollOffset)
//         scrollView.subviews.first?.transform = CGAffineTransform(translationX: 0, y: translation)
//         
//         prevOffset = offset
//      }
//      
//      let hasVisibleContent = scrollView.contentOffset.y < scrollOffset
//      postFeedVC.tableView.isScrollEnabled = !hasVisibleContent
//      photoFeedVC.tableView.isScrollEnabled = !hasVisibleContent
//   }
//   
//   func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
//      scrollDidEnd(scrollView)
//   }
//   
//   func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
//      if !decelerate {
//         scrollDidEnd(scrollView)
//      }
//   }
//   
//   func scrollDidEnd(_ scrollView: UIScrollView) {
//      isDragging = false
//      scrollView.subviews.first?.transform = CGAffineTransform.identity
//      
//      scrollView.contentOffset.y = min(scrollOffset, scrollView.contentOffset.y)
//      
//      self.prevOffset = scrollOffset
//   }
   
   
}
