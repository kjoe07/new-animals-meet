//
//  listPictures.swift
//  AnimalsMeet
//
//  Created by Sacha IFRAH on 04/12/2016.
//  Copyright © 2016 AnimalsMeet. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON
import PromiseKit

class FeedViewController : EasyTableViewController<MediaModel, MediaCell> {
    var endpoint: String!
	var didScroll: Bool?
    var searchTerm: String?{
        didSet{
            print("se inicio el valor dela busqueda: \(String(describing: searchTerm))")
			//self.searchFilter()
            if let search = searchTerm{
                print("no es nill: \(search)")
                self.SearchUser(for: search)
                //self.search(searchFor: search)
            }else{
                print("elinando datos de la busqueda")
                User = nil
            }/**/
			
			/*User = theData.filter{
				($0.author.nickname?.contains(self.searchTerm!))! || $0.animal.name.contains(self.searchTerm!)
				/*$0.nickname == searchTerm || ($0.animals?.contains(where: {
					$0.name == searchTerm
				}))!*/
			}*/
			//self.tableView.reloadData()
        }
    }/* */
	var searchJSON: [MediaModel]?
    var userJson: [JSON]!
    var i : Int?
    //var User : [MediaModel]? //[UserModel]?
	var User: [UserModel]?
    //var updateDelegate: update?
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 300
        pullToRefreshEnabled = true
        loadingEnabled = true
        paginated = false
        title = "Actualités"
        //loadUser()
    }
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		print("Aparecio Mando a Cargar")
		//_ = self.shouldRefresh()
		self.shouldLoadMore()
		/*if let didScroll = self.didScroll{
			if !didScroll{
				self.tableView.reloadData()
				let appDelegate = UIApplication.shared.delegate as! AppDelegate
				if let postID = appDelegate.postID, let data = theData {
					print("entro en la condicion")
					
					if let i = data.index(where: { data in
						//print("el valor de Data.Index: \(data.id)")
						data.id == postID
					}){
						print("i value: \(String(describing: i))")
						let indexPath = IndexPath.init(row: i, section: 0)
						self.tableView.scrollToRow(at: indexPath , at: .top, animated: true)
						appDelegate.postID = nil
						print("el valor de post id \(String(describing: appDelegate.postID))")
						// let i = data.index(where: { data in
						//   data.id == postID
						//})
						/*print("i value: \(i)")
						let indexPath = IndexPath.init(row: i!, section: 0)
						feedFriends.feedVC.tableView.scrollToRow(at: indexPath , at: .top, animated: true)
						appDelegate.postID = nil
						print("el valor de post id \(String(describing: appDelegate.postID))")*/
						
					}
				}
			}
		}*/
	}
    override func fetchItems(from: Int, count: Int) -> Promise<[MediaModel]> {
        print("entrando a fetch items")
        let c = Api.instance.get(endpoint).then { JSON -> [MediaModel] in
            JSON["json"].arrayValue.map {
                MediaModel(fromJSON: $0)
            }
            .filter { m -> Bool in
                debugPrint(m)
                //if let searchTerm = self.searchTerm {
                //TODO: - return only one value -
                    return self.searchTerm != nil ? (((m.author.nickname?.lowercased().contains((self.searchTerm?.lowercased())!))! || m.animal.name.lowercased().contains((self.searchTerm?.lowercased())!)) /*?? false*/) : true
               // }
            } //true
        }
        print("el resultado de la busqueda \(c)")
        return c
    }
    /*override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		self.tableView.reloadData()
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        if let postID = appDelegate.postID{
            //self.pagerVC.selectedIndex = 0
            let i = theData.index(where: { data in
				//print("el valor de Data.Index: \(data.id)")
                data.id == postID
            })
            print("i value: \(String(describing: i))")
            let indexPath = IndexPath.init(row: i!, section: 0)
            self.tableView.scrollToRow(at: indexPath , at: .top, animated: true)
            appDelegate.postID = nil
            print("el valor de post id \(String(describing: appDelegate.postID))")
        }
    }*/
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchTerm == nil {
            if (theData == nil || theData.count == 0) && !loading && initializationIsDone {
                showBackgroundIfEmpty()
            } else {
                tableView.backgroundView?.removeFromSuperview()
                tableView.backgroundView = nil
                return theData == nil ? 0 : theData.count
            }
            print("retorna en los posts 0")
            return 0
        }else{
            if (User == nil || User?.count == 0) && !loading && initializationIsDone {
                showBackgroundIfEmpty()
            } else {
                tableView.backgroundView?.removeFromSuperview()
                tableView.backgroundView = nil
				print("retorna  en la busqueda \(User == nil ? 0 : User?.count)")
                return User == nil ? 0 : (User?.count)!
            }
            print("retorna  en la busqueda 0")
            return 0
        }
        
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell!
        if self.searchTerm == nil{
            print("media cell")
            cell = tableView.dequeueReusableCell(withIdentifier: "MediaCell")!
            if theData == nil {
                tableView.reloadData()
                return cell
            }
            
            onPopulateCell(item: theData[indexPath.row], cell: cell as! MediaCell)
        }else{
            print("ConversationCell")
            tableView.register(UINib(nibName: "ConversationCell", bundle: nil), forCellReuseIdentifier: "ConversationCell")
            cell = tableView.dequeueReusableCell(withIdentifier: "ConversationCell")
            if theData == nil {
                tableView.reloadData()
                return cell
            }
            self.i = indexPath.row
			onPopulateCell(item: nil/*User?[indexPath.row]*/, cell: cell as! ConversationCell)
        }
        
        return cell
    }
	override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
		/*
		if theData != nil && indexPath.row == theData.count - 1 && !loading && !bottomWasReached {
			_ = shouldLoadMore()
		}*/
	}
    override func shouldLoadMore() -> Promise<Void> {
		//let c = super.shouldLoadMore()
		print("going to load more")
        super.loading = true
        let dataCount = theData == nil ? 0 : theData.count
        let c = fetchItems(from: dataCount, count: pageSize).then { items -> () in
            
            self.bottomWasReached = items.count == 0 || (!self.paginated && self.theData != nil)
            
            if self.theData == nil {
                self.theData = []
            }
            
            if self.paginated {
                self.theData.append(contentsOf: items)
            } else {
                self.theData = items
            }
            
            self.loading = false
            self.tableView.reloadData()
			let appDelegate = UIApplication.shared.delegate as! AppDelegate
			if let postID = appDelegate.postID{
				print("postId has a value in ShouldLoadMore: \(postID)")
				if let theData = self.theData{
					print("the Data is not nil: \(theData.count)")
					if let i = theData.index(where: { data in
						data.id == postID
					}){
						print("i value: \(String(describing: i))")
						let indexPath = IndexPath.init(row: i, section: 0)
						self.tableView.scrollToRow(at: indexPath , at: .top, animated: true)
						appDelegate.postID = nil
						print("el valor de post id \(String(describing: appDelegate.postID))")
					}
				}
			}

            }.always {
                self.loading = false
                self.indicator.isHidden = true
                self.indicator.removeFromSuperview()
        }/**/
                return c
    }
    override func onPopulateCell(item: MediaModel?, cell: UITableViewCell) {
        print("Mostrando la Celda")
        if self.searchTerm == nil{
            print("no hay busqueda")
            let cell =  cell as! MediaCell
            if let item = item {
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
						//profileVC.shouldHideNavigationBar = false
						self.navigationController?.pushViewController(profileVC, animated: true)
					}
				}
                cell.goToComments = {
                    self.navigationController?.hidesBottomBarWhenPushed = true
                    self.navigationController?.pushViewController(CommentViewController.newInstance(item), animated: true)
                }
            }
        //print("estableciendo el delgado de la celda \(String(describing: updateDelegate))")
        //print("el item a mostrar \(item)")
        //cell.delegate = self.updateDelegate
        }else{
            if let myuser = User?[i!]{
            print("resultado de la Busqueda")
            let cell = cell as! ConversationCell
				let animal = myuser.animals![0]//User?[i!].animal
            //cell.index
            cell.profilePic.rounded()
            cell.profilePic.kf.setImage(with: myuser.image/*item?.author.image *//*userJson[i!]["image"].url author.*/)
            cell.name.text = myuser.nickname//userJson[i!]["nickname"].stringValue //(item1)author.item?.author.nickname
            cell.lastMsg.isHidden = true
            cell.lastMsgTime.isHidden = true
                /*let y = self.theData.index(where: { data in
                    data.id == userJson[i!]["id"].intValue
                })
                let item1  = theData[y!]*/
            cell.onClick {
				let profileVC = AnimalVC.newInstance(animal)
				//profileVC.shouldHideNavigationBar = false
                self.navigationController?.pushViewController(profileVC, animated: true)
            }//goToProfile = {
                /**/
            
            //}
            /*cell.goToComments = {
                self.navigationController?.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(CommentViewController.newInstance(item), animated: true)
            }*/
            }
        }
        
    }
    /*func search(searchFor string: String){
       User = userJson.map{
            UserModel(fromJSON: $0)
            }.filter{ m -> Bool in
                var isornot: Bool!
               // (m.nickname?.lowercased().contains(string.lowercased()))! || m.animals?.contains(where: $0.name == string)  //contains(where: animal.name = string) ? true : false
                if (m.nickname?.lowercased().contains(string.lowercased()))!{
                    isornot = true
                }else{
                    //return false
                    if m.animals != nil {
                        for animal in m.animals!{
                            if animal.name.lowercased().contains(string){
                                isornot = true
                                break
                            }
                        }
                    }else{
                        isornot = false
                    }
                }
                return isornot
        }
        print("los valores de la busqueda \(String(describing: User))")
        self.tableView.reloadData()
        //_ = shouldLoadMore()
    }*/
    func loadUser(){
        let endpoint = "/user"
       _ = Api.instance.get(endpoint).then {JSON in
            // print("the Json in response promise \(JSON)")
            self.userJson =  JSON["users"].arrayValue
        }
    }
    func SearchUser(for name :String){
        let endpoint = "/user?search=\(name)&&animal=true"
        Api.instance.get(endpoint).then {JSON in
            // print("the Json in response promise \(JSON)")
            self.User =  JSON["users"].arrayValue.map{
                UserModel(fromJSON: $0)
            }
        }.always {
             _ =  self.shouldRefresh()// self.tableView.reloadData()
        }
    }/**/
	override func shouldRefresh() -> Promise<Void> {
		return shouldLoadMore()
	}
	override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		/*if self.photos {
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
				}/
			}else{
				if isempty {
					return 280.0
				}else{
					return 120.0
				}
			}
		}else{
			
				return 220.0
			
			
		}*/
		if self.searchTerm == nil {
		if self.theData[indexPath.row].isText{
			return 220.0
		}else{
			
			let height = CGFloat(theData.count > 0 ? theData[indexPath.row].width : 0 )
			let width = CGFloat(theData.count > 0 ? theData[indexPath.row].height : 0)
			let scaleFactor = UIScreen.main.scale
			let screenWidth = CGFloat(UIScreen.main.bounds.width)
			var value  = (height / (width / (screenWidth * scaleFactor))) / scaleFactor + 100
			/*if theData[indexPath.row].contentText != nil {
				value += 150.0
			}*/
			return value > 0 ? value : 100
			}}else{
			return 150.0
		}
		
		return 0

	}
	/*func searchFilter(){
		if searchTerm != ""{
			let data =	theData.filter{ m -> Bool in
				self.searchTerm != nil ? (((m.author.nickname?.lowercased().contains((self.searchTerm?.lowercased())!))! || m.animal.name.lowercased().contains((self.searchTerm?.lowercased())!)) /*?? false*/) : true
			}
			User = data.reduce([], {
				$0.contains($1) ? $0 : $0 + [$1]
			})
		}
		self.tableView.reloadData()
	}*/
	
}
extension String {
	
	func contains(_ find: String) -> Bool{
		return self.range(of: find) != nil
	}
	
	func containsIgnoringCase(_ find: String) -> Bool{
		return self.range(of: find, options: .caseInsensitive) != nil
	}
}
public extension Sequence where Iterator.Element: Hashable {
	var uniqueElements: [Iterator.Element] {
		return Array( Set(self) )
	}
}
