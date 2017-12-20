//
//  AnimalTableViewController.swift
//  AnimalsMeet
//
//  Created by Yoel JImenez del Valle on 19/12/17.
//  Copyright © 2017 AnimalsMeet. All rights reserved.
//

import UIKit
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

class AnimalTableViewController: UITableViewController,UIGestureRecognizerDelegate, FusumaDelegate{
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
	@IBOutlet weak var containerHeight: NSLayoutConstraint!
	@IBOutlet weak var animalButtonConstraintRight: NSLayoutConstraint!
	//MARK: - Properties -
	var animal: AnimalModel!
	var user: UserModel!
	let addFriendBgColor = #colorLiteral(red: 0.7540688515, green: 0.7540867925, blue: 0.7540771365, alpha: 1)
	let tabFontSize: CGFloat = 18
	let button = UIButton()
	var isTVC = false
	lazy var animalListVC: AnimalListTableViewController = self.makeAndAddVC()
	var tabsVC: ProfileTabViewController!
	var loadedanimalsfixme = false
	var realCount = 0
	var imageData: [MediaModel]!
	var postData: [MediaModel]!
	var selectedIndex = 0
	var initializationIsDone = false
	var loadingEnabled = false
	var loading = false
	lazy private var backgroundViewWhenDataIsEmpty: UIView = {return ViewUseful.instanceFromNib("EmptyTableBG")}()
	var pageSize = 20
	var paginated = true
	var bottomWasReached = false
	//MARK: - View Functions -
    override func viewDidLoad() {
        super.viewDidLoad()
		self.tableView.estimatedSectionHeaderHeight = 40.0
		self.automaticallyAdjustsScrollViewInsets = false

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
		myAccount.roundify()
		animalsButton.roundify()
		addFriendButton.roundify()
		addFriendButton.isEnabled = user != nil && user.followers != nil
		sendMessageButton.roundify()
		plume.roundify()
		plume.backgroundColor = #colorLiteral(red: 0.4651720524, green: 0.7858714461, blue: 0.9568093419, alpha: 1)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		switch self.selectedIndex {
		case 0 - 1:
		
			if (imageData == nil || imageData.count == 0) && !loading && initializationIsDone {
				showBackgroundIfEmpty()
			} else {
				tableView.backgroundView?.removeFromSuperview()
				tableView.backgroundView = nil
				return imageData == nil ? 0 : imageData.count
			}
		case 2:
			if (postData == nil || postData.count == 0) && !loading && initializationIsDone {
				showBackgroundIfEmpty()
			} else {
				tableView.backgroundView?.removeFromSuperview()
				tableView.backgroundView = nil
				return postData == nil ? 0 : postData.count
			}
		default:
			if (imageData == nil || imageData.count == 0) && !loading && initializationIsDone {
				showBackgroundIfEmpty()
			} else {
				tableView.backgroundView?.removeFromSuperview()
				tableView.backgroundView = nil
				return imageData == nil ? 0 : imageData.count
			}
		}
		
        return 0
    }

    /**/
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		switch self.selectedIndex {
		case 0:
			let cell = tableView.dequeueReusableCell(withIdentifier: "MediaCell", for: indexPath)
			if imageData == nil {
				tableView.reloadData()
				return cell
			}
			
			onPopulateCell(item: imageData[indexPath.row], cell: cell)
			return cell
		case 1:
			let cell = tableView.dequeueReusableCell(withIdentifier: "MediaCell", for: indexPath)
			if imageData == nil {
				tableView.reloadData()
				return cell
			}
			
			onPopulateCell(item: imageData[indexPath.row], cell: cell)
			return cell
		default:
			let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
			return cell
		}
		//let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

		// return cell
    }


    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */
	override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
		let items = ["Photos", "Posts","Photos Grid"]
		let customSC = UISegmentedControl(items: items)
		let v = UIView()
		customSC.selectedSegmentIndex = 0
		customSC.frame = CGRect.init(x: 15, y: 15, width: UIScreen.main.bounds.width - 30.0 , height: 30.0)
		//return customSC
		v.addSubview(customSC)
		return v
	}
	override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
		switch self.selectedIndex {
		case 0 - 1:
			if imageData != nil && indexPath.row == imageData.count - 1 && !loading && !bottomWasReached {
				_ = shouldLoadMore()
			}
		case 2:
			if postData != nil && indexPath.row == postData.count - 1 && !loading && !bottomWasReached {
				_ = shouldLoadMore()
			}
		default:
			if imageData != nil && indexPath.row == imageData.count - 1 && !loading && !bottomWasReached {
				_ = shouldLoadMore()
			}
		}
		
	}
	func showBackgroundIfEmpty() {
		if tableView.backgroundView != nil {
			tableView.backgroundView?.removeFromSuperview()
		}
		tableView.backgroundView = backgroundViewWhenDataIsEmpty
	}
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
	//MARK: - Class Functions -
	func makeAndAddVC<T: UIViewController>() -> T {
		let vc = T()
		self.addChildViewController(vc)
		return vc
	}
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
	/*@objc(cropViewController:didCropToImage:withRect:angle:) func cropViewController(_ cropViewController: TOCropViewController, didCropToImage image: UIImage, rect cropRect: CGRect, angle: Int) {
		cropViewController.dismiss(animated: true) { () -> Void in}}
	func cropViewController(_ cropViewController: TOCropViewController, didFinishCancelled cancelled: Bool) {
		cropViewController.dismiss(animated: true) { () -> Void in  }
	}*/
	
	/*func configureNavigationBar() {
		if shouldHideNavigationBar {
			//navigationController!.setNavigationBarHidden(true, animated: false)
		}
		navigationController?.navigationBar.isTranslucent = true
	}*/
	//MARK: - Profile Actions
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
	func setUser(_ user: UserModel) {
		self.user = user
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
		animalProfilePic.kf.setImage(with: animal.profilePicUrl,placeholder: nil,options: [.transition(.fade(1))],progressBlock: nil,completionHandler: nil)
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
	//MARK: - Data load task -
	func fetchUserImages(from: Int, count: Int) -> Promise<[MediaModel]> {
		if imageData == nil {
			realCount = 0
		}
		let c = Api.instance.get("/user/\(self.user.id!)/images/\(self.realCount)").then { JSON -> [MediaModel] in
				// PATCH: count the number of items without being filtered
				self.realCount += JSON["images"].arrayValue.count
				
				return JSON["images"].arrayValue.map {
					MediaModel(fromJSON: $0)
					}.filter {
						$0.animal.id != 0
				}
			}
		return c
	}
	func fetchItems(from: Int, count: Int) -> Promise<[MediaModel]> {
		return Api.instance.get("/user/\(self.user.id!)/posts/\(from)")
			.then { JSON -> [MediaModel] in
				JSON["posts"].arrayValue.map {
					MediaModel(fromJSON: $0)
			}
		}
	}
	func shouldLoadMore() /*-> Promise<Void> */{
		loading = true
		switch self.selectedIndex {
		case 0 - 1:
			let dataCount = imageData == nil ? 0 : imageData.count
			fetchUserImages(from: dataCount, count: pageSize).then { items -> () in
				
				self.bottomWasReached = items.count == 0 || (!self.paginated && self.imageData != nil)
				
				if self.imageData == nil {
					self.imageData = []
				}
				
				if self.paginated {
					self.imageData.append(contentsOf: items)
				} else {
					self.imageData = items
				}
				
				self.loading = false
				self.tableView.reloadData()
				}.always {
					self.loading = false
					//self.indicator.isHidden = true
					//self.indicator.removeFromSuperview()
			}
		case 2:
			let dataCount = postData == nil ? 0 : postData.count
			fetchItems(from: dataCount, count: pageSize).then { items -> () in
				
				self.bottomWasReached = items.count == 0 || (!self.paginated && self.postData != nil)
				
				if self.postData == nil {
					self.postData = []
				}
				
				if self.paginated {
					self.postData.append(contentsOf: items)
				} else {
					self.postData = items
				}
				
				self.loading = false
				self.tableView.reloadData()
				}.always {
					self.loading = false
					//self.indicator.isHidden = true
					//self.indicator.removeFromSuperview()
			}
		default:
			print("error en el swicht")
		}
		
	}
	func onPopulateCell(item: AnyObject?, cell: UITableViewCell) {
		switch self.selectedIndex {
		case 0,3:
			let cell = cell as! MediaCell
			if let item = item as? MediaModel {
				cell.profilePic.rounded()
				cell.setMedia(item)
				
				if !(item ).isText {
					cell.mediaView.onTap {_ in
						presentFullScreen(imageURL: (item).url, onVC: self, media: item)
						//                presentFullScreen(imageURL: item.url, onVC: self)
					}
				}
				if item.author.id != App.instance.userModel.id{
					cell.goToProfile = {
						let profileVC = AnimalVC.newInstance((item ).animal)
						profileVC.shouldHideNavigationBar = false
						self.navigationController?.pushViewController(profileVC, animated: true)
					}
				}
				cell.goToComments = {
					self.navigationController?.hidesBottomBarWhenPushed = true
					self.navigationController?.pushViewController(CommentViewController.newInstance(item), animated: true)
				}
			}
		case 1:
			break
		
		default:
			print("error en el swicht en populate")
		}
	}
}
extension AnimalTableViewController{
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
