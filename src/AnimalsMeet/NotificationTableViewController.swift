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
        if theData != nil {
            theData = nil
        }
        return shouldLoadMore()
    }
    
    func fetchItems(from: Int, count: Int) -> Promise<[NotificationModel]> {
        return Api.instance.get("/notification")
            .then { JSON -> [NotificationModel] in
                if self.theData != nil && self.theData.count > 0 {
                    return []
                }
                return JSON["notifs"].map { NotificationModel(fromJSON: $1) }
            }
    }
    
    func shouldLoadMore() -> Promise<Void> {
        
        loading = true
        let dataCount = theData == nil ? 0 : theData.count
        return fetchItems(from: dataCount, count: pageSize).then { items -> () in
            if self.theData == nil {
                self.theData = []
            }
            
            self.bottomWasReached = items.count == 0
            self.theData.append(contentsOf: items)
            self.loading = false
            self.tableView.reloadData()
            }.always {
                self.loading = false
                self.indicator.isHidden = true
                self.indicator.removeFromSuperview()
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if (theData == nil || theData.count == 0) && !loading {
            showBackgroundIfEmpty()
        } else {
            backgroundViewWhenDataIsEmpty.removeFromSuperview()
            return theData == nil ? 0 : theData.count
        }
        
        return 0
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        if theData == nil {
            return
        }
        
        if indexPath.row == theData.count - 1 && !loading && !bottomWasReached {
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
            return cell
        }
        
        let notification = theData[indexPath.row]
        
        if let updateDate = notification.updatedAt {
            cell.dateLabel.text = try! updateDate.colloquialSinceNow().colloquial
        }
        
        if let animal = notification.animal {
            
            cell.setNotificationContent(from: animal.name, action: notification.type)
            cell.profilePic.hnk_setImageFromURL(animal.profilePicUrl)
            
        } else {
            
            let userName = "@\(notification.user.nickname!)"
            
            cell.setNotificationContent(from: userName, action: notification.type)
            cell.profilePic.kf.setImage(with: notification.user.image)
        }
        cell.luLabel.isHidden = true // Client ne veut pas du "lu"
        cell.onTap { _ in
            if let animal = notification.animal {
                let vc = AnimalVC.newInstance(animal)
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
        
        return cell
    }
}

