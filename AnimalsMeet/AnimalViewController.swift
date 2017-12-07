/*//
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

class AnimalVC: UIViewController, UIGestureRecognizerDelegate, FusumaDelegate, PageTabBarControllerDelegate{
    //MARK: - Oulets -
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
    //@IBOutlet weak var infoViewHeiht: NSLayoutConstraint!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var infoView: UIView!
    @IBOutlet weak var feed: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var animalButtonConstraintRight: NSLayoutConstraint!
    @IBOutlet weak var containerHeight: NSLayoutConstraint!
    //MARK: - properties -
    var animal: AnimalModel!
    var user: UserModel!
    var shouldHideNavigationBar = true
    let addFriendBgColor = #colorLiteral(red: 0.7540688515, green: 0.7540867925, blue: 0.7540771365, alpha: 1)
    var loadedanimalsfixme = false
    let tabFontSize: CGFloat = 18
    let button = UIButton()
    var isTVC = false
    let screenHeight = UIScreen.main.bounds.height
    let scrollViewContentHeight = 3000 as CGFloat
    lazy var photoFeedVC: UserPicsTableViewController = self.makeAndAddVC()
    lazy var postFeedVC: PostFeedVC = self.makeAndAddVC()
    lazy var animalListVC: AnimalListTableViewController = self.makeAndAddVC()
    lazy var collectionVC = MosaicViewController(collectionViewLayout: UICollectionViewFlowLayout())
    var tabsVC: ProfileTabViewController!
    var selectedViewController: UITableViewController! {
        didSet {
            //selectedViewController.tableView.isUserInteractionEnabled = false
            //         let bottomInset = self.selectedViewController.tableView.contentSize.height - feed.bounds.height + 44
            //         self.scrollView.contentInset.bottom = max(0, bottomInset)
        }
    }
    //MARK: - View Functions -
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.delegate = self
        //containerView.frame.size.height += 150
        //self.feed.frame.size.height += 150.0
        //self.scrollView.contentSize.height = containerView.height + 10.0
        if user == nil && animal != nil {
            user = UserModel()
            user.id = animal.ownerId
            if user.isMe {
                user = App.instance.userModel
            }
        }
        if user == nil {
            setUser(App.instance.userModel!) //was commented
        }
        tabsVC = ProfileTabViewController(viewControllers: [photoFeedVC, postFeedVC])
        tabsVC.delegate = self
        self.selectedViewController = photoFeedVC
        postFeedVC.pageTabBarItem.title = "Posts"
        postFeedVC.pageTabBarItem.titleColor = .gray
        photoFeedVC.pageTabBarItem.title = "Photos"
        photoFeedVC.pageTabBarItem.titleColor = .gray
        /*photoFeedVC.tableView.snp.makeConstraints({(make) -> Void in
            make.bottom.equalTo(containerView)
        })
        postFeedVC.tableView.snp.makeConstraints({ make -> Void in
            make.bottom.equalTo(self.view)
        })*/
        //photoFeedVC.tableView.backgroundColor = .gray
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
        collectionVC.endpoint = "/user/\(self.user.id ?? 0 )/images/0"
        collectionVC.jsonIndex = "images"
        addChildViewController(collectionVC)
        addMosaicButton()
        //self.selectedViewController.tableView.delegate = self
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("aparece la vista")
        
        var profileLoadPromise: Promise<Void>!
        
        print(self.scrollView.height)
        print(self.feed.frame.size.height)
        print("el offset del scroll: \(scrollView.contentOffset.y)")
        print("el offset del tableView: \(photoFeedVC.tableView.contentOffset.y)")
        print("el height del navigation bar \(self.navigationController?.navigationBar.height)")
        print("el heigth del tableview: \(selectedViewController.tableView.contentSize)")
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
            if (me.animals ?? []).count == 0 {
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
        //containerHeight.constant += 400.0
        //containerView.frame.size.height = infoView.bounds.height + feed.bounds.height + infoView.height/2
    }
    //MARK:  ViewDidAppear
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        /*print("aparecio la vista")
        print("la altura del feed \(feed.height)")
        scrollView.contentSize.height = infoView.bounds.height + feed.bounds.height + 190.0
        selectedViewController.tableView.isUserInteractionEnabled = false
        //containerView.frame.size.height = infoView.bounds.height + feed.bounds.height + 170.0//bounds.size.height = infoView.bounds.height + feed.bounds.height + 170.0
        //feed.bounds.size.height += 170.0
        //feed.frame.size.height += 230.0
        //containerHeight.constant += 400.0
        /*containerView.frame.size.height += infoView.bounds.height
        photoFeedVC.tableView.isUserInteractionEnabled = false
        postFeedVC.tableView.isUserInteractionEnabled = false
        self.feed.frame.size.height += infoView.bounds.height
        self.photoFeedVC.tableView.frame.size.height += infoView.bounds.height
        self.postFeedVC.tableView.frame.size.height += infoView.bounds.height
        containerHeight.constant = infoView.bounds.height
        self.scrollView.contentSize.height = containerView.height + 10*/
        self.scrollView.layoutIfNeeded()
        //print("el tamaño del container \(containerView.frame.height)")
        //scrollView.layoutSubviews()*/
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        //feed.bounds.size.height -= 170.0
        //containerHeight.constant -= 400.0
        //containerView.frame.size.height -= 230.0//infoView.bounds.height
        //self.feed.frame.size.height -= infoView.bounds.height
        //self.photoFeedVC.tableView.frame.size.height -= infoView.bounds.height
        //self.postFeedVC.tableView.frame.size.height -= infoView.bounds.height
        //self.scrollView.contentSize.height = containerView.height + 10/**/
    }
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        configureNavigationBar()
        //self.containerView.frame.size.height = self.scrollView.contentSize.height
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrollView.translatesAutoresizingMaskIntoConstraints = true
        
    }
    
    func createView(_ frame: CGRect, height: CGFloat?) -> UIView {
        var frame = frame
        if let h = height {
            frame.size.height = h
        }
        return UIView(frame: frame)
    }
    //MARK: - Class Functions -
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
        cropViewController.dismiss(animated: true) { () -> Void in}
    }
    func cropViewController(_ cropViewController: TOCropViewController, didFinishCancelled cancelled: Bool) {
        cropViewController.dismiss(animated: true) { () -> Void in  }}
    
    func configureNavigationBar() {
        if shouldHideNavigationBar {
            //navigationController!.setNavigationBarHidden(true, animated: false)
        }
        navigationController?.navigationBar.isTranslucent = true
    }
    func pageTabBarController(pageTabBarController: PageTabBarController, didTransitionTo viewController: UIViewController) {
        self.selectedViewController = viewController as? UITableViewController
        
        if viewController == photoFeedVC {
            postFeedVC.pageTabBarItem.titleLabel!.font = UIFont.systemFont(ofSize: tabFontSize)
            photoFeedVC.pageTabBarItem.titleLabel!.font = UIFont.boldSystemFont(ofSize: tabFontSize)
            button.isHidden = false
        } else {
            photoFeedVC.pageTabBarItem.titleLabel!.font = UIFont.systemFont(ofSize: tabFontSize)
            postFeedVC.pageTabBarItem.titleLabel!.font = UIFont.boldSystemFont(ofSize: tabFontSize)
            button.isHidden = true
        }
    }
    func makeAndAddVC<T: UIViewController>() -> T {
        let vc = T()
        self.addChildViewController(vc)
        return vc
    }
    //MARK: - setup funtions -
    func addMosaicButton() {
        let padding: CGFloat = 16
        button.imageEdgeInsets = UIEdgeInsets(top: padding, left: padding, bottom: padding, right: padding)
        button.clipsToBounds = true
        button.backgroundColor = #colorLiteral(red: 0, green: 0.620670259, blue: 0.8846479654, alpha: 1)
        button.layer.cornerRadius = 30
        button.addTarget(self, action: #selector(swapControllers), for: .touchUpInside)
        setButtonImage()
        self.view.addSubview(button)
        button.snp.makeConstraints { make in
            make.right.equalToSuperview().inset(20)
            make.bottom.equalToSuperview().inset(40)
            make.width.equalTo(60)
            make.height.equalTo(60)
        }
    }
    
    func swapControllers() {
        if !isTVC {
            let s = feed.superview!
            feed.isHidden = true
            s.addSubview(collectionVC.view)
            collectionVC.view.frame = feed.frame
        } else {
            collectionVC.view.removeFromSuperview()
            feed.isHidden = false
        }
        self.view.bringSubview(toFront: button)
        isTVC = !isTVC
        setButtonImage()
    }
    
    func setButtonImage() {
        button.setImage(isTVC ? #imageLiteral(resourceName: "list") : #imageLiteral(resourceName: "grid"), for: .normal)
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
                    self.followersCount.text = "\(self.user.followersCount!)"
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
    
    func setProfilePic(_ sender: Any) {
        let fusuma = FusumaViewController()
        fusuma.delegate = self
        fusuma.hasVideo = false
        fusuma.allowMultipleSelection = false
        self.present(fusuma, animated: true, completion: nil)
    }
    //MARK: - Fusuma Delegate -
    func fusumaImageSelected(_ image: UIImage, source: FusumaMode) {
        
        let imageData = UIImageJPEGRepresentation(image, 0.3)!
        
        let media = MediaModel()
        media.rawData = imageData.base64EncodedString(options: .lineLength64Characters)
        media.callForCreate(taggedUser: nil).then { json -> Void in
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
    
}

extension AnimalVC: UIScrollViewDelegate {
   /* func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        print("delegado en accion ")
        let tableView = self.selectedViewController.tableView!
        
        print("el offset del tableView \(tableView.contentOffset.y)")
        
        if scrollView.panGestureRecognizer.velocity(in: scrollView.superview).y > 0 {
            //            isDown = false
            print("Direction down")
            if tableView.contentOffset.y == 0 {
                tableView.isUserInteractionEnabled = false
                scrollView.isScrollEnabled = true
            }
        } else {
            print("Direction up")
            if scrollView.contentOffset.y > self.infoView.height - ((self.navigationController?.navigationBar.height)! + 20){
                //self.photoFeedVC.tableView.isUserInteractionEnabled = true
                //self.postFeedVC.tableView.isUserInteractionEnabled = true
                //if tableView.contentOffset <
                scrollView.isScrollEnabled = false
                tableView.isUserInteractionEnabled = true
                
            }
            
        }
        /*let offset = scrollView.contentOffset
        let bounds = infoView.bounds//scrollView.bounds
        let size = infoView.frame.size
        let inset = scrollView.contentInset
        let y: Float = Float(offset.y) + Float(bounds.size.height) + Float(inset.bottom)
        let height: Float = Float(size.height)
        let distance: Float = 10
        print("el offset \(offset)")
        print("content size \(size)")
        print("el inset \(inset)")
        print("el valor de y: \(y)")
        print("el valor de height \(height)")
        print("la altura del contentsize del scroll: \(scrollView.contentSize.height)")
        print("la altura del feed \(feed.height)")
        let tableView = self.selectedViewController.tableView!
        if y > height + distance{
            print("es mayor")
            
            
            tableView.isUserInteractionEnabled = true
            scrollView.resignFirstResponder()
            print("using tableView scroll")
        }else{
            print("no es mayor")
            /*tableView.isUserInteractionEnabled = false
            tableView.resignFirstResponder()
            print("using scrollView scroll")*/
            if tableView.contentOffset.y == 0 {
                //tableViews content is at the top of the tableView.
                tableView.isUserInteractionEnabled = false
                tableView.resignFirstResponder()
                print("using scrollView scroll offset 0")
            } else {
                //UIView is in frame, but the tableView still has more content to scroll before resigning its scrolling over to ScrollView.
                tableView.isUserInteractionEnabled = true
                scrollView.resignFirstResponder()
                print("using tableView scroll")
            }
        }*/
        
       /* let tableView = self.selectedViewController.tableView!
        
        print("el offset del tableView \(tableView.contentOffset.y)")
        if scrollView.contentOffset.y > self.infoView.height - ((self.navigationController?.navigationBar.height)! + 20){
            //self.photoFeedVC.tableView.isUserInteractionEnabled = true
            //self.postFeedVC.tableView.isUserInteractionEnabled = true
            //if tableView.contentOffset <
            scrollView.isScrollEnabled = false
            tableView.isUserInteractionEnabled = true
            
        }else{
            if tableView.contentOffset.y == 0 {
                tableView.isUserInteractionEnabled = false
            }
            
        }*/
        /* let tableView = self.selectedViewController.tableView!
         if !scrollView.bounds.contains(infoView.frame){ // intersects(infoView.frame) == true {
         print("contentOffset.y del tableview \(tableView.contentOffset.y)")
         if tableView.contentOffset.y == 0 {
         //tableViews content is at the top of the tableView.
         tableView.isUserInteractionEnabled = false
         tableView.resignFirstResponder()
         print("using scrollView scroll")
         } else {
         //UIView is in frame, but the tableView still has more content to scroll before resigning its scrolling over to ScrollView.
         tableView.isUserInteractionEnabled = true
         scrollView.resignFirstResponder()
         print("using tableView scroll")
         }
         }else{
         //UIView is not in frame. Use tableViews scroll.
         print("normal size")
         tableView.isUserInteractionEnabled = true
         scrollView.resignFirstResponder()
         print("using tableView scroll")
         
         }*/
    }
}*/
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        /*let tableView = self.selectedViewController.tableView!
        /*print("el offset del tableView \(tableView.contentOffset.y)")
        if scrollView.panGestureRecognizer.velocity(in: scrollView.superview).y > 0 {
            //            isDown = false
            print("Direction down")
            if tableView.contentOffset.y == 0 {
                tableView.isUserInteractionEnabled = false
                scrollView.isScrollEnabled = true
                tableView.resignFirstResponder()
            }
        }else{
            print("Direction up")
            if scrollView.contentOffset.y > self.infoView.height - ((self.navigationController?.navigationBar.height)! + 20){
                //self.photoFeedVC.tableView.isUserInteractionEnabled = true
                //self.postFeedVC.tableView.isUserInteractionEnabled = true
                //if tableView.contentOffset <
                scrollView.isScrollEnabled = false
                tableView.isUserInteractionEnabled = true
                scrollView.resignFirstResponder()
            }
        }*/
        if scrollView.contentOffset.y > self.infoView.height - ((self.navigationController?.navigationBar.height ?? 24) + 20){
        //!scrollView.bounds.contains(infoView.frame){ scrollView.bounds.intersects(infoView.frame) == true {
            print("contentOffset.y del tableview \(tableView.contentOffset.y)")
            if tableView.contentOffset.y == 0 {
                //tableViews content is at the top of the tableView.
                tableView.isUserInteractionEnabled = false
                tableView.resignFirstResponder()
                print("using scrollView scroll")
            } else {
                //UIView is in frame, but the tableView still has more content to scroll before resigning its scrolling over to ScrollView.
                tableView.isUserInteractionEnabled = true
                scrollView.resignFirstResponder()
                print("using tableView scroll")
            }
        }else{
            //UIView is not in frame. Use tableViews scroll.
            print("normal size")
            tableView.isUserInteractionEnabled = true
            scrollView.resignFirstResponder()
            print("using tableView scroll")
            
        }
    }
}
/*
 //        var isDown = false
 /* if scrollView.panGestureRecognizer.velocity(in: scrollView.superview).y > 0 {
 //            isDown = false
 print("Direction up")
 self.infoViewHeiht.constant = 230.0
 } else {
 print("Direction down")
 self.infoViewHeiht.constant = 0.0
 }*/
 /* print(infoView.bounds.origin.y)
 if infoView.bounds.maxY == infoView.frame.origin.y{
 print("se mueve por encima de su posicion")
 }else { //if infoView.bounds.maxY{
 print("vuelve a su lugar")
 }*/
 let offset = scrollView.contentOffset
 let bounds = scrollView.bounds
 let size = scrollView.contentSize
 let inset = scrollView.contentInset
 let y: Float = Float(offset.y) + Float(bounds.size.height) + Float(inset.bottom)
 let height: Float = Float(size.height)
 let distance: Float = 10
 print("el offset \(offset)")
 print("content size \(size)")
 print("el inset \(inset)")
 print("el valor de y: \(y)")
 print("el valor de height \(height)")
 print("la altura del contentsize del scroll: \(scrollView.contentSize.height)")
 print("la altura del feed \(feed.height)")
 if y > height + distance {
 print("hacia Arriba")//self.checkNew()
 
 ///nfoViewHeiht.constant = 0.0
 //feed.frame.size.height += infoView.height
 }else{
 //infoViewHeiht.constant = 230.0
 //feed.frame.size.height -= infoView.height
 print("Abajo")
 }
 */
 */
 let tableView = self.selectedViewController.tableView!
 if scrollView.bounds.intersects(infoView.frame) == true {
 
 
 if tableView.contentOffset.y == 0 {
 //tableViews content is at the top of the tableView.
 
 tableView.isUserInteractionEnabled = false
 tableView.resignFirstResponder()
 print("using scrollView scroll")
 
 } else {
 
 //UIView is in frame, but the tableView still has more content to scroll before resigning its scrolling over to ScrollView.
 
 tableView.isUserInteractionEnabled = true
 scrollView.resignFirstResponder()
 print("using tableView scroll")
 }
 
 } else {
 
 //UIView is not in frame. Use tableViews scroll.
 print("normal size")
 tableView.isUserInteractionEnabled = true
 scrollView.resignFirstResponder()
 print("using tableView scroll")
 
 }
 }
}//*/
 //}*/
 /**/
 //extension AnimalVC: UIScrollViewDelegate {
 //    func scrollViewDidScroll(_ scrollView: UIScrollView) {
 //        print(scrollView.contentOffset.y)
 //        let offset = scrollView.contentOffset.y
 //
 //        if offset > scrollOffset {
 //            isDragging = true
 //        }
 //
 //        if isDragging {
 //            let delta = offset - prevOffset
 //            let tableView = self.selectedViewController.tableView!
 //            tableView.contentOffset.y += delta
 //            tableView.flashScrollIndicators()
 //
 //            let translation = max(0, offset - scrollOffset)
 //            scrollView.subviews.first?.transform = CGAffineTransform(translationX: 0, y: translation)
 //
 //            prevOffset = offset
 //        }
 //        let hasVisibleContent = scrollView.contentOffset.y < scrollOffset
 //
 //
 //        self.selectedViewController.tableView.isScrollEnabled = !hasVisibleContent
 ////        postFeedVC.tableView.isScrollEnabled = !hasVisibleContent
 ////        photoFeedVC.tableView.isScrollEnabled = !hasVisibleContent
 //    }
 //
 //    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
 //        scrollDidEnd(scrollView)
 //    }
 //
 //    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
 //        if !decelerate {
 //            scrollDidEnd(scrollView)
 //        }
 //    }
 //
 //    func scrollDidEnd(_ scrollView: UIScrollView) {
 //        isDragging = false
 //        scrollView.subviews.first?.transform = CGAffineTransform.identity
 //
 //        scrollView.contentOffset.y = min(scrollOffset, scrollView.contentOffset.y)
 //
 //        self.prevOffset = scrollOffset
 //    }
 //}*/
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

class AnimalVC: UIViewController, UIGestureRecognizerDelegate, FusumaDelegate, PageTabBarControllerDelegate/*, update */{
    
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
    @IBOutlet weak var containerHeight: NSLayoutConstraint!
    var animal: AnimalModel!
    var user: UserModel!
    var shouldHideNavigationBar = true
    let addFriendBgColor = #colorLiteral(red: 0.7540688515, green: 0.7540867925, blue: 0.7540771365, alpha: 1)
    
    let tabFontSize: CGFloat = 18
    
    let button = UIButton()
    var isTVC = false
    
    @IBOutlet weak var infoView: UIView!
    @IBOutlet weak var feed: UIView!
    
    @IBOutlet weak var scrollView: UIScrollView!
    let screenHeight = UIScreen.main.bounds.height
    let scrollViewContentHeight = 3000 as CGFloat
    
    func makeAndAddVC<T: UIViewController>() -> T {
        let vc = T()
        self.addChildViewController(vc)
        return vc
    }
    
    lazy var photoFeedVC: UserPicsTableViewController = self.makeAndAddVC()
    lazy var postFeedVC: PostFeedVC = self.makeAndAddVC()
    lazy var animalListVC: AnimalListTableViewController = self.makeAndAddVC()
    lazy var collectionVC = MosaicViewController(collectionViewLayout: UICollectionViewFlowLayout())
    
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
        
        if user == nil {
            setUser(App.instance.userModel!)
        }
        
        tabsVC = ProfileTabViewController(viewControllers: [photoFeedVC, postFeedVC])
        tabsVC.delegate = self
        
        self.selectedViewController = photoFeedVC
        
        postFeedVC.pageTabBarItem.title = "Posts"
        postFeedVC.pageTabBarItem.titleColor = .gray
        photoFeedVC.pageTabBarItem.title = "Photos"
        photoFeedVC.pageTabBarItem.titleColor = .gray
        //postFeedVC.updateDelegate = self
        
        
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
        
        collectionVC.endpoint = "/user/\(self.user.id!)/images/0"
        collectionVC.jsonIndex = "images"
        addChildViewController(collectionVC)
        
        addMosaicButton()
        
        /*
         view.onPan(when: .always, handle: { (panGestureRecognizer) in
         self.topConstraint.constant += panGestureRecognizer.translation(in: self.view).y
         }, configure: nil)
         */
        
        //        scrollView.delegate = self
        
        
        //        let v = createView(self.view.frame, height: 230)
        //        v.addSubview(infoView)
        //        infoView.snp.makeConstraints { make in
        //            make.top.equalToSuperview()
        //            make.bottom.equalToSuperview()
        //            make.left.equalToSuperview()
        //            make.right.equalToSuperview()
        //        }
        //        scrollView.contentView.addSubview(v)
        
        //        let v1 = createView(self.tabsVC.view.frame, height: nil)
        //        v1.backgroundColor = UIColor.red
        //        v1.addSubview(tabsVC.view)
        //        scrollView.contentView.addSubview(v1)
        
        //        scrollView.contentView.addSubview(selectedViewController.view)
    }
    
    func createView(_ frame: CGRect, height: CGFloat?) -> UIView {
        var frame = frame
        if let h = height {
            frame.size.height = h
        }
        return UIView(frame: frame)
    }
    
    func addMosaicButton() {
        let padding: CGFloat = 16
        button.imageEdgeInsets = UIEdgeInsets(top: padding, left: padding, bottom: padding, right: padding)
        button.clipsToBounds = true
        button.backgroundColor = #colorLiteral(red: 0, green: 0.620670259, blue: 0.8846479654, alpha: 1)
        button.layer.cornerRadius = 30
        button.addTarget(self, action: #selector(swapControllers), for: .touchUpInside)
        setButtonImage()
        self.view.addSubview(button)
        button.snp.makeConstraints { make in
            make.right.equalToSuperview().inset(20)
            make.bottom.equalToSuperview().inset(40)
            make.width.equalTo(60)
            make.height.equalTo(60)
        }
    }
    
    func swapControllers() {
        if !isTVC {
            let s = feed.superview!
            feed.isHidden = true
            s.addSubview(collectionVC.view)
            collectionVC.view.frame = feed.frame
        } else {
            collectionVC.view.removeFromSuperview()
            feed.isHidden = false
        }
        self.view.bringSubview(toFront: button)
        isTVC = !isTVC
        setButtonImage()
    }
    
    func setButtonImage() {
        button.setImage(isTVC ? #imageLiteral(resourceName: "list") : #imageLiteral(resourceName: "grid"), for: .normal)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        var profileLoadPromise: Promise<Void>!
        
        if user == nil {
            setUser(App.instance.userModel!)
        }
        
        if user.isMe {
            //App.instance.userModel = UserModel.getProfilUser()
            _ = App.instance.requestUserBreedsAndAnimals()
            let me = App.instance.userModel!
            setUser(me)
            userProfilePic.kf.setImage(with: me.image)
            userProfilePic.onTap { _ in
                if self.user.id == App.instance.userModel.id {
                    self.setProfilePic(self)
                }
            }
            
            if (me.animals ?? []).count == 0 {
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
                    self.followersCount.text = "\(self.user.followersCount!)"
                }
                let message = self.user.isFriend() ? "Vous suivez maintenant cette personne" : "Vous ne suivez plus cette personne"
                alert.showAlertSuccess(title: "Ami", subTitle: message)
                //App.instance.userModel = UserModel.getProfilUser()
               _ = App.instance.requestUserBreedsAndAnimals()
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
        
        scrollView.translatesAutoresizingMaskIntoConstraints = true
        
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
        media.callForCreate(taggedUser: nil).then { json -> Void in
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
            button.isHidden = false
        } else {
            photoFeedVC.pageTabBarItem.titleLabel!.font = UIFont.systemFont(ofSize: tabFontSize)
            postFeedVC.pageTabBarItem.titleLabel!.font = UIFont.boldSystemFont(ofSize: tabFontSize)
            button.isHidden = true
        }
    }
    /*func updateView() {
        print("delegate in like")
        self.view.setNeedsLayout()
        self.view.layoutIfNeeded()
    }*/
    
    //    var isDragging = false
    //
    //    let scrollOffset: CGFloat = 166
    //
    //    var prevOffset: CGFloat = 166
}

extension AnimalVC: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
       /* //        var isDown = false
        //        if scrollView.panGestureRecognizer.velocity(in: scrollView.superview).y > 0 {
        //            isDown = false
        //            print("Direction up")
        //        } else {
        //            isDown = true
        //            print("Direction down")
        //        }
        if scrollView == self.scrollView {
            print("el scroll")
        }else{
            print("el tableview")
        }
        print("el offset\(scrollView.contentOffset.y)")
       
        let tableView = self.selectedViewController.tableView!
         print("el offset del tableView \(tableView.contentOffset.y)")
        
        if scrollView.contentOffset.y > 0.0 && tableView.contentOffset.y == 0.0{
            /*if tableView.contentOffset.y {
                
            }*/
            UIView.animateKeyframes(withDuration: 0.3, delay: 0.0, options: [], animations: {
                self.containerHeight.constant = 0.0
            }, completion: nil)
            print("mayor")
        }else if tableView.contentOffset.y < 0{
            UIView.animateKeyframes(withDuration: 0.3, delay: 0.0, options: [], animations: {
                self.containerHeight.constant = 230.0
            }, completion: nil)
            print("menor")
        }
        /*if scrollView.bounds.(infoView.frame) == true {
            //the UIView is within frame, use the UIScrollView's scrolling.
            print("intersecta")
            self.containerHeight.constant = 0.0
            if tableView.contentOffset.y == 0 {
                //tableViews content is at the top of the tableView.
                tableView.isUserInteractionEnabled = false
                tableView.resignFirstResponder()
                print("using scrollView scroll")
                
            } else {
                
                //UIView is in frame, but the tableView still has more content to scroll before resigning its scrolling over to ScrollView.
                
                tableView.isUserInteractionEnabled = true
                scrollView.resignFirstResponder()
                print("using tableView scroll")
            }
            
        } else {
            self.containerHeight.constant = 230.0
            self.view.layoutIfNeeded()
            //UIView is not in frame. Use tableViews scroll.
            
            tableView.isUserInteractionEnabled = true
            scrollView.resignFirstResponder()
            print("using tableView scroll")
            
        }*/*/
    }
}

//extension AnimalVC: UIScrollViewDelegate {
//    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        print(scrollView.contentOffset.y)
//        let offset = scrollView.contentOffset.y
//
//        if offset > scrollOffset {
//            isDragging = true
//        }
//
//        if isDragging {
//            let delta = offset - prevOffset
//            let tableView = self.selectedViewController.tableView!
//            tableView.contentOffset.y += delta
//            tableView.flashScrollIndicators()
//
//            let translation = max(0, offset - scrollOffset)
//            scrollView.subviews.first?.transform = CGAffineTransform(translationX: 0, y: translation)
//
//            prevOffset = offset
//        }
//        let hasVisibleContent = scrollView.contentOffset.y < scrollOffset
//
//
//        self.selectedViewController.tableView.isScrollEnabled = !hasVisibleContent
////        postFeedVC.tableView.isScrollEnabled = !hasVisibleContent
////        photoFeedVC.tableView.isScrollEnabled = !hasVisibleContent
//    }
//
//    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
//        scrollDidEnd(scrollView)
//    }
//
//    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
//        if !decelerate {
//            scrollDidEnd(scrollView)
//        }
//    }
//    
//    func scrollDidEnd(_ scrollView: UIScrollView) {
//        isDragging = false
//        scrollView.subviews.first?.transform = CGAffineTransform.identity
//        
//        scrollView.contentOffset.y = min(scrollOffset, scrollView.contentOffset.y)
//        
//        self.prevOffset = scrollOffset
//    }
//}
