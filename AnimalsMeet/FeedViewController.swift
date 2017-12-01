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
    var searchTerm: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 300
        pullToRefreshEnabled = true
        loadingEnabled = true
        paginated = false
        title = "Actualités"
        
    }
    
    override func fetchItems(from: Int, count: Int) -> Promise<[MediaModel]> {
        print("entrando a fetch items")
        let c = Api.instance.get(endpoint).then { JSON -> [MediaModel] in
            JSON["json"].arrayValue.map {
                MediaModel(fromJSON: $0)
            }
            .filter { m -> Bool in
                debugPrint(m)
                return self.searchTerm != nil ? (m.author.nickname?.lowercased().contains(self.searchTerm.lowercased()) ?? false) : true
            } //true
        }
        print("el resultado de la busqueda \(c)")
        return c
    }
    /*override func viewDidAppear(_ animated: Bool) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        if let postID = appDelegate.postID{
            //self.pagerVC.selectedIndex = 0
            let i = theData.index(where: { data in
                data.id == postID
            })
            print("i value: \(i)")
            let indexPath = IndexPath.init(row: i!, section: 0)
            self.tableView.scrollToRow(at: indexPath , at: .top, animated: true)
            appDelegate.postID = nil
            print("el valor de post id \(String(describing: appDelegate.postID))")
        }
    }*/
    override func shouldLoadMore() -> Promise<Void> {
        
        super.loading = true
        let dataCount = theData == nil ? 0 : theData.count
        return fetchItems(from: dataCount, count: pageSize).then { items -> () in
            
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
                //self.pagerVC.selectedIndex = 0
                let i = self.theData.index(where: { data in
                    data.id == postID
                })
                print("i value: \(i)")
                let indexPath = IndexPath.init(row: i!, section: 0)
                self.tableView.scrollToRow(at: indexPath , at: .top, animated: true)
                appDelegate.postID = nil
                print("el valor de post id \(String(describing: appDelegate.postID))")
            }
            }.always {
                self.loading = false
                self.indicator.isHidden = true
                self.indicator.removeFromSuperview()
        }
    }
    override func onPopulateCell(item: MediaModel, cell: MediaCell) {
        
        cell.profilePic.rounded()
        cell.setMedia(item)
        
        if !item.isText {
            cell.mediaView.onTap {_ in
               presentFullScreen(imageURL: item.url, onVC: self, media: item)
//                presentFullScreen(imageURL: item.url, onVC: self)
            }
        }

        cell.goToProfile = {
            let profileVC = AnimalVC.newInstance(item.animal)
            profileVC.shouldHideNavigationBar = false
            self.navigationController?.pushViewController(profileVC, animated: true)
        }
        cell.goToComments = {
            self.navigationController?.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(CommentViewController.newInstance(item), animated: true)
        }
    }
}
