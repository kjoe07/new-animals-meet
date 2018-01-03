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
            if let search = searchTerm{
                print("no es nill: \(search)")
                self.SearchUser(for: search)
                //self.search(searchFor: search)
            }else{
                print("elinando datos de la busqueda")
                User = nil
            }
        }
    }/* */
    
    var userJson: [JSON]!
    var i : Int?
    var User : [UserModel]?
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
		_ = self.shouldRefresh()
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
            onPopulateCell(item: nil, cell: cell as! ConversationCell)
        }
        
        return cell
    }
	override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
		
		/*if theData != nil && indexPath.row == theData.count - 1 && !loading && !bottomWasReached {
			_ = shouldLoadMore()
		}*/
	}
    override func shouldLoadMore() -> Promise<Void> {
		//let c = super.shouldLoadMore()
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
                let animal = User?[i!].animals?[0]
            //cell.index
            cell.profilePic.rounded()
            cell.profilePic.kf.setImage(with: myuser.image/*userJson[i!]["image"].url author.*/)
            cell.name.text = myuser.nickname//userJson[i!]["nickname"].stringValue //(item1)author.
            cell.lastMsg.isHidden = true
            cell.lastMsgTime.isHidden = true
                /*let y = self.theData.index(where: { data in
                    data.id == userJson[i!]["id"].intValue
                })
                let item1  = theData[y!]*/
            cell.onClick {
                let profileVC = AnimalVC.newInstance(animal!)
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
    func search(searchFor string: String){
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
    }
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
    }
	override func shouldRefresh() -> Promise<Void> {
		return shouldLoadMore()
	}
   
}
