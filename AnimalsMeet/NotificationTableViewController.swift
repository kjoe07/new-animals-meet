//
//  NotificationTableViewController.swift
//  AnimalsMeet
//
//  Created by Adrien Morel on 05/12/2016.
//  Copyright © 2016 AnimalsMeet. All rights reserved.
//

import UIKit
import SwiftyJSON
import AFDateHelper
import PromiseKit
import PullToRefreshSwift
import SwiftDate

// FIXME: show notification badges in tab. TODO: use easy table view
class NotificationTableViewController: UITableViewController {
    
    class BackgroundDescription {
        let title = "Il n'y a rien ici"
        var subtitle: String?
        var image: UIImage?
    }
    
    var theData: [NotificationModel]!
    var bottomWasReached = false
    lazy var indicator = UIActivityIndicatorView()
    
    var downloadMethod: Useful.ApiGetter!
    var backgroundViewWhenDataIsEmpty: UIView {
        return ViewUseful.instanceFromNib("EmptyTableBG")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadingEnabled = true
        loading = true
        pullToRefreshEnabled = true
    }
    
    var pullToRefreshEnabled = false {
        didSet {
            self.tableView.addPullRefresh {
                self.shouldRefresh()
                    .always {
                        self.tableView.stopPullRefreshEver()
                    }.catch { err in
                        print(err)
                }
            }
        }
    }
    var loadingEnabled = false {
        didSet {
            tableView.addSubview(indicator)
            indicator.isHidden = false
            indicator.startAnimating()
            indicator.color = .gray
            _ = shouldLoadMore() // TODO error image
        }
    }
    var loading = false
    var pageSize = 6
    
    public func fetchMethod(_ getter: Useful.ApiGetter) {
        downloadMethod = getter
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if loadingEnabled {
            indicator.frame = tableView.frame
        }
    }
    
    func shouldRefresh() -> Promise<Void> {
        return shouldLoadMore()
    }
    
    func fetchItems(from: Int, count: Int) -> Promise<[NotificationModel]> {
        let c =  Api.instance.get("/notification")
            .then { JSON -> [NotificationModel] in
                /*if self.theData != nil && self.theData.count > 0 {
					print("retorna arreglo vacioa")
                    return []
                }*/

                return JSON["notifs"].map { NotificationModel(fromJSON: $1) }
            }
		return c
    }
    
    func shouldLoadMore() -> Promise<Void> {
        
        loading = true
        let dataCount = theData == nil ? 0 : theData.count
        let c =  fetchItems(from: dataCount, count: pageSize).then { items -> () in
            if self.theData == nil {
				print("no inicializado el arreglo")
                self.theData = []
			}else {
				print("Datos el valor: \(self.theData)")
				self.theData.removeAll()
			}
			print()
            self.bottomWasReached = items.count == 0
			//self.theData.append(contentsOf: items)
			self.theData = items
			print("los elementos en theData \(self.theData.count)")
            self.loading = false
			print("reloading tableView")
            self.tableView.reloadData()
			self.bottomWasReached = true
            }.always {
                self.loading = false
                self.indicator.isHidden = true
                self.indicator.removeFromSuperview()
        }
		return c
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if (theData == nil || theData.count == 0) && !loading {
			print("vacia la tabla")
            showBackgroundIfEmpty()
        } else {
            backgroundViewWhenDataIsEmpty.removeFromSuperview()
			print("numero de row: \(theData == nil ? 0 : theData.count)")
            return theData == nil ? 0 : theData.count
        }
        
        return 0
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        if theData == nil {
			print("al display es nil")
            return
        }
        
        if indexPath.row == theData.count - 1 && !loading && !bottomWasReached {
			print("vacio o en el fondo")
            _ = shouldLoadMore()
        }
    }
    
    func showBackgroundIfEmpty() {
        tableView.backgroundView = backgroundViewWhenDataIsEmpty
        if tableView.tableFooterView == nil {
            tableView.tableFooterView = UIView()
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath) as! NotificationTableViewCell
        
        if theData == nil {
			print("nil the data in cell for row")
            return cell
        }
        
        let notification = theData[indexPath.row]
       print("notification: \(notification.user.nickname!)")
		cell.isUserInteractionEnabled = true
        //debugPrint("notification: \(notification.user)")
        //NSLog("notification", notification)
        
        if let updateDate = notification.updatedAt {
            cell.dateLabel.text = updateDate.localizedString
        }
        
        if let animal = notification.animal {
            print("mostrando el animal \(animal.name!)")
            cell.setNotificationContent(from: animal.name, action: notification.type)
            cell.profilePic.hnk_setImageFromURL(animal.profilePicUrl)
            
        } else {
            
            let userName = "@" + notification.user.nickname!//"@\(notification.user.nickname!)"
            
            cell.setNotificationContent(from: userName, action: notification.type)
            cell.profilePic.kf.setImage(with: notification.user.image)
        }
        cell.luLabel.isHidden = true // Client ne veut pas du "lu"
        cell.onTap { _ in
            if let animal = notification.animal {
                let vc = AnimalVC.newInstance(animal)
                self.navigationController?.pushViewController(vc, animated: true)
            }else if let type = notification.type {
                if type == 1{
                    self.tabBarController?.selectedIndex = 3
                    //let newchatVC = ChatTableViewController()
                    //self.navigationController?.pushViewController(newchatVC, animated: true)
                }else if type == 0 || type == 3{
					cell.postID = notification.postId
                    //let newFedVC = NewsViewController()
                    //self.navigationController?.pushViewController(newFedVC, animated: true)
                    /*if (self.tabBarController?.viewControllers?[0] as! NewsBaseViewController).pagerVC.pageViewController != (self.tabBarController?.viewControllers?[0] as! NewsBaseViewController).feedFriends{
                        (self.tabBarController?.viewControllers?[0] as! NewsBaseViewController).pagerVC.selectedIndex = 0
                        
                    }//selected //feedFriends.endpoint = ""
                    (self.tabBarController?.viewControllers?[0] as! NewsBaseViewController).feedFriends.endpoint = "/feeds/friends?\(notification.user.id)"*/
                    /*if ((self.tabBarController?.viewControllers?[0] as! NewsBaseViewController).pagerVC) != nil{
                        (self.tabBarController?.viewControllers?[0] as! NewsBaseViewController).pagerVC.selectedIndex = 0
                    }
                    (self.tabBarController?.viewControllers?[0] as! NewsBaseViewController).feedFriends.postId = 81*/
                    let appDelgate = UIApplication.shared.delegate as! AppDelegate
                    // FIXME: - Update to real post id comming from Notification endpoint
					//print("post Id to AppDelegate \(String(describing: self.theData[indexPath.row].postId ?? 0))")
					appDelgate.postID = self.theData[indexPath.row].postId ?? nil//cell.postID//notification.postId
                    
                    self.tabBarController?.selectedIndex = 0
                    
                }/*else if type == 2 {
                    let vc = AnimalVC.newInstance(notification.user)
                    self.navigationController?.pushViewController(vc, animated: true)
                }*/
                
            }
        }
        
        return cell
    }
	
	/*override func viewWillAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		_ = self.shouldRefresh()
	}*/

}

