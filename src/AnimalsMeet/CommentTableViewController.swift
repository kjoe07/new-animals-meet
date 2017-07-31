//
//  CommentTableViewController.swift
//  AnimalsMeet
//
//  Created by Adrien morel on 02/05/2017.
//  Copyright © 2017 AnimalsMeet. All rights reserved.
//

import UIKit
import PromiseKit

class CommentTableViewController: EasyTableViewController<CommentModel, CommentTableViewCell> {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 140
        loadingEnabled = true
        pullToRefreshEnabled = true
        paginated = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        (self.tabBarController as! AnimalTabBarController).centerButton.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        (self.tabBarController as! AnimalTabBarController).centerButton.isHidden = false
    }
    
    override func fetchItems(from: Int, count: Int) -> Promise<[CommentModel]> {
        
        var coms = [CommentModel]()
        
        return Api.instance.get("/media/\((parent as! CommentViewController).media.id!)/comments")
            .then { JSON -> [CommentModel] in
                for j in JSON["comments"].arrayValue {
                    coms.append(CommentModel(fromJSON: j))
                }
                return coms
        }
    }
    
    override func onPopulateCell(item: CommentModel, cell: CommentTableViewCell) {
        cell.configure(comment: item)
        cell.like.onTap { _ in
            
            if item.iLiked {
            _ = Api.instance.post("/media/comment/\(item.id!)/unlike")
                item.likeCount! -= 1
                item.iLiked = false
            } else {
                if item.id != nil {
                    _ = Api.instance.post("/media/comment/\(item.id!)/like")
                    item.likeCount! += 1
                    item.iLiked = true
                }
            }
            
            cell.updateLikeCount(comment: item)
        }
        cell.answer.onTap { _ in
            let input = (self.parent as! CommentViewController).commentInput
            input!.text = "@\(item.author.nickname!) \(input?.text ?? "")"
            input?.becomeFirstResponder()
        }
    }
}
