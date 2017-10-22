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
        
        return Api.instance.get(endpoint).then { JSON -> [MediaModel] in
            JSON["json"].arrayValue.map {
                MediaModel(fromJSON: $0)
            }
            .filter { m -> Bool in
                return self.searchTerm != nil ? (m.author.name?.lowercased().contains(self.searchTerm.lowercased()) ?? true) : true }
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
