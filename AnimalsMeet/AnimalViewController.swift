//
//  profileTableViewController.swift
//  AnimalsMeet
//
//  Created by Yoel JImenez del Valle on 25/12/17.
//  Copyright © 2017 AnimalsMeet. All rights reserved.
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
import PullToRefreshSwift
class AnimalVC: UIViewController, FusumaDelegate, UICollectionViewDelegate,UICollectionViewDataSource, UITableViewDelegate,UITableViewDataSource {
	@IBOutlet weak var segementedControl: UISegmentedControl!
	var profileHeader: headerView!
	var photos = true
	var grid = false
	let button = UIButton()/*UIButton(frame: CGRect(x: UIScreen.main.bounds.size.width - 80, y: UIScreen.main.bounds.size.height - 110 , width: 60.0 , height: 60))*/
	var user: UserModel!
	var animal: AnimalModel!
	lazy var animalListVC: AnimalListTableViewController = self.makeAndAddVC()
	let addFriendBgColor = #colorLiteral(red: 0.7540688515, green: 0.7540867925, blue: 0.7540771365, alpha: 1)
	var userImage: [MediaModel]!
	var userPost: [MediaModel]!
	var gridImages: [[MediaModel]]!
	var singlegrid: [MediaModel]!
	var realCount: Int?
	var pageSize = 20
	var isempty = true
	@IBOutlet weak var tableView: UITableView!
	lazy private var backgroundViewWhenDataIsEmpty: UIView = {
		return ViewUseful.instanceFromNib("EmptyTableBG")
	}()
	lazy var indicator = UIActivityIndicatorView()
	//var shouldHideNavigationBar = true
	override func viewDidLoad() {
		super.viewDidLoad()
		
		if user == nil && animal != nil {
			user = UserModel()
			user.id = animal.ownerId
			if user.isMe {
				user = App.instance.userModel
			}
		}
		if let _profile = Bundle.main.loadNibNamed("headerView", owner: self, options: nil)?.first as? headerView{
			print("no es nil el prefil")
			self.profileHeader = _profile
			self.tableView.tableHeaderView = _profile
			//self.tableView.tableHeaderView = _profile
		}
		let cellNib = UINib(nibName: "MediaCell", bundle: nil)
		self.tableView.register(cellNib, forCellReuseIdentifier: "MediaCell")
		self.tableView.register(UINib(nibName:"emptyTableViewCell",bundle: nil), forCellReuseIdentifier: "empty")
		self.tableView.sectionHeaderHeight = 40.0
		self.automaticallyAdjustsScrollViewInsets = false
		if user == nil {
			setUser(App.instance.userModel!)
		}
		//_ = self.shouldLoadMore()
		//_ = self.shouldLoadMorePost()
		tableView.scrollIndicatorInsets = UIEdgeInsetsMake(self.profileHeader.height + 35.0, 0, 0, 0)
		//TODO: - if user is not me the myAccount should not be visible -
		self.profileHeader.myAccount.roundify()
		self.profileHeader.myAccount.addTarget(self, action: #selector(self.goAccount(_:)), for: .touchUpInside)
		self.profileHeader.animalsButton.roundify()
		self.profileHeader.animalsButton.addTarget(self, action: #selector(self.displayAnimalList(_:)), for: .touchUpInside)
		self.profileHeader.addFriendButton.roundify()
		self.profileHeader.addFriendButton.isEnabled = user != nil && user.followers != nil
		self.profileHeader.addFriendButton.addTarget(self, action: #selector(self.follow(_:)), for: .touchUpInside)
		self.profileHeader.sendMessageButton.roundify()
		//self.profileHeader.sendMessageButton.addTarget(self, action: #selector(self.talkTo(_:)), for: .touchUpInside)
		self.profileHeader.plume.roundify()
		self.profileHeader.plume.backgroundColor = #colorLiteral(red: 0.4651720524, green: 0.7858714461, blue: 0.9568093419, alpha: 1)
		self.profileHeader.plume.addTarget(self, action: #selector(self.doPost), for: .touchUpInside)
		addMosaicButton()
		self.profileHeader.FriendsButton.addTarget(self, action: #selector(showFollowers(_:)), for: .touchUpInside)
		self.profileHeader.suivis.onTap {_ in
			//print("suivis Tap")
			self.showSuivis(sender: self)
		}
		self.profileHeader.sendMessageButton.addTarget(self, action: #selector(self.talkTo(_:)), for: .touchUpInside)
		self.tableView.addPullRefresh {
			if self.photos {
				self.shouldLoadMore()
					.always {
						self.tableView.stopPullRefreshEver()
					}.catch { err in
						self.showBackgroundIfEmpty(/*err*/)
				}
			}else {
				self.shouldLoadMorePost()
					.always {
						self.tableView.stopPullRefreshEver()
					}.catch { err in
						self.showBackgroundIfEmpty()//self.showBackgroundError(err)
				}
			}
		}
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
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
			self.profileHeader.userProfilePic.kf.setImage(with: me.image)
			self.profileHeader.userProfilePic.onTap { _ in
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
			}
			profileLoadPromise = Promise(value: ())
			setUser(user)
		} else {
			profileLoadPromise = Api.instance.get("/user/\(animal.ownerId!)").then { json -> Void in
				self.setUser(UserModel(fromJSON: json["user"]))
				self.profileHeader.userProfilePic.kf.setImage(with: self.user?.image)
			}
			self.profileHeader.userProfilePic.onTap {_ in
				presentFullScreen(image: self.profileHeader.userProfilePic.image!, onVC: self, media: nil)
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
		animalListVC.createAnimal = {
			self.editAnimal(animal: nil)
		}
	}
	// MARK: - Table view data source
	func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if photos {
			if !grid{
				print("total a mostrar nogrid:\(userImage != nil ? userImage.count : 0)")
				if userImage == nil || userImage.count == 0 {
					print("una celda")
					return 1
				}else {
					print("mas de una \(userImage.count)")
					return userImage.count
				}
			}else{
				if gridImages == nil || gridImages.count == 0{
					return 1
				}else{
					print("total a mostrar grid: \(gridImages != nil ? gridImages.count : 0)")
					return  gridImages.count
				}
			}
		}else{
			print("cargando el post")
			if userPost == nil || userPost.count == 0 {
				print("userpost es nil o tiene 0 \(self.userPost)")
				return 1
			}else {
				print("total a mostrar \(userPost != nil ? userPost.count : 0)")
				return userPost.count
			}
		}
		//return 0
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		if self.photos {
			if !grid {
				if userImage == nil || userImage.count == 0 {
					self.isempty = true
					let cell = tableView.dequeueReusableCell(withIdentifier: "empty", for: indexPath)
					return cell
				}else {
					let cell = tableView.dequeueReusableCell(withIdentifier: "MediaCell", for: indexPath)as! MediaCell
					if userImage == nil {
						tableView.reloadData()
						return cell
					}
					self.isempty = false
					onPopulateCell(item: userImage[indexPath.row], cell: cell )
					return cell
				}
			}else{
				if gridImages == nil || gridImages.count == 0 {
					self.isempty = true
					let cell = tableView.dequeueReusableCell(withIdentifier: "empty", for: indexPath)
					return cell
				}else{
					self.isempty = false
					let cell = tableView.dequeueReusableCell(withIdentifier: "gridcell", for: indexPath) as! gridTableViewCell
					cell.myCollecttion.register(UINib.init(nibName: "MosaicCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "MosaicCollectionViewCell")
					cell.setCollectionViewDataSourceDelegate(dataSourceDelegate: self, forRow: indexPath.row )
				}
			}
		}else{
			if userPost == nil || userPost.count == 0 {
				self.isempty = true
				let cell = tableView.dequeueReusableCell(withIdentifier: "empty", for: indexPath)
				return cell
			}else{
				self.isempty =  false
				let cell = tableView.dequeueReusableCell(withIdentifier: "MediaCell", for: indexPath) as! MediaCell
				if userImage == nil {
					tableView.reloadData()
					return cell
				}
				onPopulateCell(item: userPost[indexPath.row], cell: cell)
				return cell
			}
		}
		return UITableViewCell()
		//return cell
	}
	func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
		if self.userPost == nil || self.gridImages == nil || self.userPost == nil {
			_ = self.shouldLoadMore()
			_ = self.shouldLoadMorePost()
		}
	}
	func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
		let cell = tableView.dequeueReusableCell(withIdentifier: "sectionHeader") as! sectionTableViewCell
		cell.segmentedControl.selectedSegmentIndex = self.photos ? 0 : 1
		return cell
	}
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		if self.photos {
			if !grid {
				if !isempty{
					let height = CGFloat(userImage.count > 0 ? userImage[indexPath.row].width : 0 )
					let width = CGFloat(userImage.count > 0 ? userImage[indexPath.row].height : 0)
					let scaleFactor = UIScreen.main.scale
					let screenWidth = CGFloat(UIScreen.main.bounds.width)
					let value  = (height / (width / (screenWidth * scaleFactor))) / scaleFactor + 100
					return value > 0 ? value : 100
				}else{
					return 280.0
				}//*
			}else{
				if isempty {
					return 280.0
				}else{
					return 120.0
				}
			}
		}else{
			if isempty {
				return 280.0
			}else{
				return 220.0
			}
			
		}
		return 0
	}
	/*
	// MARK: - Navigation
	
	@IBOutlet weak var valueChanged: UISegmentedControl!
	// In a storyboard-based application, you will often want to do a little preparation before navigation
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
	// Get the new view controller using segue.destinationViewController.
	// Pass the selected object to the new view controller.
	}
	*/
	func doPost(){
		self.performSegue(withIdentifier: "doPost", sender: self)
	}
	func goAccount(_ sender: Any){
		print("go Account")
		self.performSegue(withIdentifier: "perfil", sender: self)
	}
	@IBAction func valueChanged(_ sender: UISegmentedControl) {
		switch sender.selectedSegmentIndex {
		case 0:
			print("el valor 0")
			self.photos = true
			UIView.animate(withDuration: 0.3, animations: {_ in
				self.button.alpha = 1.0
			})
		case 1:
			print("el 1")
			self.photos = false
			UIView.animate(withDuration: 0.3, animations: {_ in
				self.button.alpha = 0.0
			})
		default:
			print("default")
		}
		
		for views in self.tableView.subviews{
			if views.isKind(of: MediaCell.self){
				print("removing the cell")
				views.removeFromSuperview()
			}else if views.isKind(of: gridTableViewCell.self){
				print("removing the Collection cell")
				views.removeFromSuperview()
			}
		}
		self.tableView.reloadData()
	}
	func onPopulateCell(item: MediaModel?, cell: MediaCell) {
		print("llenando la celda")
		if let item = item {
			print("hay item")
			cell.profilePic.rounded()
			cell.setMedia(item)
			if !(item ).isText {
				print("no es item")
				cell.mediaView.onTap {_ in
					presentFullScreen(imageURL: (item).url, onVC: self, media: item)
				}
			}
			cell.goToComments = {
				self.navigationController?.hidesBottomBarWhenPushed = true
				self.navigationController?.pushViewController(CommentViewController.newInstance(item), animated: true)
			}
		}
	}
	func segmentedChanged(sender: UISegmentedControl){
		print("changing value in segmented")
		switch sender.selectedSegmentIndex {
		case 0:
			print("0 selected")
			self.photos = true
			
		//sender.selectedSegmentIndex = 0
		case 1:
			print("1 selected")
			self.photos = false
		//sender.selectedSegmentIndex = 1
		default:
			self.tableView.reloadData()
		}
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
		self.view.bringSubview(toFront: button)
		self.view.sendSubview(toBack: self.tableView)
		button.layer.masksToBounds = false
		button.layer.shadowColor = #colorLiteral(red: 0.7540688515, green: 0.7540867925, blue: 0.7540771365, alpha: 1).cgColor //CGColor
		button.layer.shadowOpacity = 1.0
		button.layer.shadowOffset = CGSize.zero
		button.layer.shadowRadius = 5
		button.snp.makeConstraints { make in
			make.right.equalToSuperview().inset(20)
			make.bottom.equalToSuperview().inset(40)
			make.width.equalTo(60)
			make.height.equalTo(60)
		}/**/
	}
	func swapControllers() {
		self.view.bringSubview(toFront: button)
		grid = !grid
		print("Grid value: \(grid)")
		for views in self.tableView.subviews{
			if views.isKind(of: MediaCell.self){
				print("removing the cell")
				views.removeFromSuperview()
			}else if views.isKind(of: gridTableViewCell.self){
				print("removing the Collection cell")
				views.removeFromSuperview()
			}
		}
		self.tableView.reloadData()
		setButtonImage()
	}
	func setButtonImage() {
		button.setImage(grid ? #imageLiteral(resourceName: "list") : #imageLiteral(resourceName: "grid"), for: .normal)
	}
	func displayAnimalList(_ sender: Any) {
		animalListVC.user = self.user
		navigationController?.pushViewController(animalListVC, animated: true)
	}
	func follow(_ sender: UIButton) {
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
					self.profileHeader.followersCount.text = "\(self.user.followersCount!)"
				}
				let message = self.user.isFriend() ? "Vous suivez maintenant cette personne" : "Vous ne suivez plus cette personne"
				alert.showAlertSuccess(title: "Ami", subTitle: message)
				//App.instance.userModel = UserModel.getProfilUser()
				_ = App.instance.requestUserBreedsAndAnimals()
			}.catch(execute: App.showRequestFailure)
	}
	func showFollowers(_ sender: Any) {
		if let users = self.user?.followers, !users.isEmpty {
			let controller = UserListViewController(users: users)
			let title = "Abonnés"
			controller.title = title
			self.navigationController?.pushViewController(controller, animated: true)
		}
	}
	func showSuivis(_ sender: Any) {
		if let users = self.user?.suivis, !users.isEmpty {
			let controller = UserListViewController(users: users)
			let title = "Suivis"
			controller.title = title
			self.navigationController?.pushViewController(controller, animated: true)
		}
	}
	
	func editAnimal(animal: AnimalModel?) {
		let vc = AnimalConfigurationViewController.newInstance(animal: animal)
		navigationController?.pushViewController(vc, animated: true)
	}
	func reloadAnimal() {
		setAnimalPicture()
		configureAnimalInfo()
	}
	
	func configureAnimalInfo() {
		self.profileHeader.animal_name_age.text = "\(animal.name!), \(animal.year!)"
		self.profileHeader.animal_breed.text = animal.breedName()
		if animal.loof && animal.heat ?? false {
			self.profileHeader.animal_state_icon_3.image = UIImage(named: "thermometer")
			self.profileHeader.animal_state_icon_4.image = UIImage(named: "family-tree")
			self.profileHeader.animal_state_icon_3.isHidden = false
			self.profileHeader.animal_state_icon_4.isHidden = false
		} else if animal.loof {
			self.profileHeader.animal_state_icon_3.image = UIImage(named: "family-tree")
			self.profileHeader.animal_state_icon_3.isHidden = false
			self.profileHeader.animal_state_icon_4.isHidden = true
		} else if animal.heat ?? false {
			self.profileHeader.animal_state_icon_3.image = UIImage(named: "thermometer")
			self.profileHeader.animal_state_icon_3.isHidden = false
			self.profileHeader.animal_state_icon_4.isHidden = true
		}
		if animal.type == "dog" {
			self.profileHeader.animal_state_icon_1.image = #imageLiteral(resourceName: "husky")
		}
		self.profileHeader.animal_localisation.text = "\(animal.distance ?? 0) Km"
	}
	
	func setAnimalPicture() {
		self.profileHeader.animalProfilePic.kf.indicatorType = .activity
		self.profileHeader.animalProfilePic.kf.setImage(with: animal.profilePicUrl,placeholder: nil, options: [.transition(.fade(1))],progressBlock: nil,completionHandler: nil)
		if self.profileHeader.animalProfilePic.image != nil {
			self.profileHeader.animalProfilePic.onTap {_ in
				presentFullScreen(image: self.profileHeader.animalProfilePic.image!, onVC: self, media: nil)
			}
		}
		self.profileHeader.animalProfilePic.center.x = self.profileHeader.userProfilePic.frame.midX + (cos(7 * .pi / 4) * self.profileHeader.userProfilePic.frame.width / 2 - 2
			- self.profileHeader.animalProfilePic.frame.width / 2 + (cos(7 * .pi / 4) * self.profileHeader.animalProfilePic.frame.width / 2))
		self.profileHeader.animalProfilePic.center.y = self.profileHeader.userProfilePic.frame.midY + (cos(7 * .pi / 4) * self.profileHeader.userProfilePic.frame.height / 2 - 2
			- self.profileHeader.animalProfilePic.frame.height / 2 + (cos(7 * .pi / 4) * self.profileHeader.animalProfilePic.frame.height / 2))
		self.profileHeader.animalProfilePic.layer.cornerRadius = self.profileHeader.animalProfilePic.frame.width / 2
		self.profileHeader.animalProfilePic.clipsToBounds = true
		
		UIKitViewUtils.setCornerRadius(sender: self.profileHeader.userProfilePic, radius: self.profileHeader.userProfilePic.frame.width / 2)
		
		if (animal.sex == .male) {
			UIKitViewUtils.setBorderWidth(sender: self.profileHeader.userProfilePic, width: 2.0, hexString: "#2978AC")
		} else {
			UIKitViewUtils.setBorderWidth(sender: self.profileHeader.userProfilePic, width: 2.0, hexString: "#E42772")
		}
	}
	func talkTo(_ sender: Any) {
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
	func makeAndAddVC<T: UIViewController>() -> T {
		let vc = T()
		self.addChildViewController(vc)
		return vc
	}
	func ajustarBotones(){
		self.profileHeader.animalsButton.frame.origin.x =  self.view.frame.width - self.profileHeader.animalsButton.width - 8.0
		self.profileHeader.myAccount.frame.origin.x =  self.view.frame.width - self.profileHeader.animalsButton.width*2 - 16.0
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
	func setUser(_ user: UserModel) {
		self.user = user
		//FIXME: fix Header VIew
		self.profileHeader.nickname.text = "@\(user.nickname!)"
		self.profileHeader.followingCount.text = "\(user.followersCount!)"
		self.profileHeader.followersCount.text = "\(user.followingCount!)"
		self.profileHeader.likeCount.text = "\(user.likeCount!)"
		self.profileHeader.myAccount.isHidden = !user.isMe
		self.profileHeader.sendMessageButton.isHidden = user.isMe
		self.profileHeader.addFriendButton.isHidden = user.isMe
		self.profileHeader.addFriendButton.isEnabled = user.followers != nil
		self.profileHeader.animal_localisation.isHidden = user.isMe
		if user.isMe {
			self.ajustarBotones()
		} else if user.isFriend() {
			self.profileHeader.addFriendButton.backgroundColor = addFriendBgColor
		}/**/
	}
	//MARK: - fetch Data
	func fetchUserImages(from: Int, count: Int) -> Promise<[MediaModel]> {
		if userImage == nil {
			realCount = 0
		}
		let c = Api.instance.get("/user/\(self.user.id!)/images/\(self.realCount!)").then { JSON -> [MediaModel] in
			return JSON["images"].arrayValue.map {
				MediaModel(fromJSON: $0)
				}.filter {
					$0.animal.id != 0
			}
		}
		return c
	}
	func fetchUserPost(from: Int) -> Promise<[MediaModel]> {
		print("entrando a fetch items")
		return Api.instance.get("/user/\(self.user.id!)/posts/0").then { JSON -> [MediaModel] in ///
			JSON["posts"].arrayValue.map {
				MediaModel(fromJSON: $0)
			}
		}
	}
	func showBackgroundIfEmpty() {
		if tableView.backgroundView != nil {
			tableView.backgroundView?.removeFromSuperview()
		}
		tableView.backgroundView = backgroundViewWhenDataIsEmpty
	}
	func shouldLoadMore() -> Promise<Void> {
		
		//loading = true
		let dataCount = userImage == nil ? 0 : userImage.count
		let c =  fetchUserImages(from: dataCount, count: pageSize).then { items -> () in
			if self.userImage == nil {
				self.userImage = []
			}
			if self.gridImages == nil {
				self.gridImages = []
			}
			self.userImage = items
			
			self.gridImages = items.chunks(3)
			self.isempty = false
			print("self userimages:\(self.userImage.count)")
			//}
			//self.loading = false
			self.tableView.reloadData()
			}.always {
		}
		return c
	}
	func shouldLoadMorePost() -> Promise<Void> {
		//loading = true
		let dataCount = userImage == nil ? 0 : userImage.count
		let c =  fetchUserPost(from: dataCount).then { items -> () in
			print("el valor items en post: \(items)")
			if self.userPost == nil {
				self.userPost = []
			}
			self.userPost = items
			print("self userPosts:\(self.userPost.count)")
			if !self.photos {
				self.tableView.reloadData()
			}
			}.always {
		}
		return c
	}
	/*func scrollViewDidScroll(_ scrollView: UIScrollView) {
	button.frame = CGRect.init(x: button.frame.origin.x, y:  UIScreen.main.bounds.size.height + scrollView.contentOffset.y - 110 , width: button.frame.width, height: button.frame.height)
	}*/
	
}
extension AnimalVC{
	func fusumaImageSelected(_ image: UIImage, source: FusumaMode) {
		let imageData = UIImageJPEGRepresentation(image, 0.3)!
		let media = MediaModel()
		media.rawData = imageData.base64EncodedString(options: .lineLength64Characters)
		media.callForCreate(taggedUser: nil).then { json -> Void in
			let createdMedia = MediaModel(fromJSON: json)
			self.user.image = createdMedia.url
			//self.userProfilePic.image = image
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
extension AnimalVC{
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return gridImages[collectionView.tag].count
	}
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MosaicCollectionViewCell", for: indexPath) as! MosaicCollectionViewCell
		
		cell.set(url: gridImages[collectionView.tag][indexPath.row].url)
		//cell.set(url: item.url)
		
		cell.contentView.onTap { _ in
			presentFullScreen(image: cell.image.image!, onVC: self, media: self.gridImages[collectionView.tag][indexPath.row])
		}
		return cell
	}
}
/*
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
		self.animalListVC.user = self.user
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
	@IBAction func showSuivis(_ sender: Any) {
		if let users = self.user?.suivis, !users.isEmpty {
			let controller = UserListViewController(users: users)
			let title = "Suivis"			
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
*/
