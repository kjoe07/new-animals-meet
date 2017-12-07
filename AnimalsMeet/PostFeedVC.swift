//
//  PostFeedVC.swift
//  AnimalsMeet
//
//  Created by gwendal lasson on 01/06/2017.
//  Copyright © 2017 AnimalsMeet. All rights reserved.
//

import UIKit
import PromiseKit
import SwiftyJSON
import UITextView_Placeholder

class PostFeedVC: /*EasyTableViewController<MediaModel, MediaCell>*/FeedViewController {
    
    var textView: UITextView!
    var user: UserModel!

    override func viewDidLoad() {
        super.viewDidLoad()
        paginated = true
        self.shouldLoadMore()
    }
    
    override func fetchItems(from: Int, count: Int) -> Promise<[MediaModel]> {
        //print("el valor from \(from)")
        //print("/user/\(self.user.id!)/posts/\(from)")
        return unready.promiseReady.then {
            Api.instance.get("/user/\(self.user.id!)/posts/\(from)").then { JSON -> [MediaModel] in
                JSON["posts"].arrayValue.map { MediaModel(fromJSON: $0) }
            }
        }
        
        
    }
   /* override func onPopulateCell(item: MediaModel, cell: MediaCell) {
        //print("estableciendo el delgado de la celda \(String(describing: updateDelegate))")
        //print("el item a mostrar \(item)")
        //cell.delegate = self.updateDelegate
        print("llenando la celda de post")
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
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //print("theData \(theData.count)")
        if (theData == nil || theData.count == 0) && !loading && initializationIsDone {
            print("the data is nil")
            showBackgroundIfEmpty()
        } else {
            tableView.backgroundView?.removeFromSuperview()
            tableView.backgroundView = nil
            return theData == nil ? 0 : theData.count
        }
        
        return 0
    }*/
}
