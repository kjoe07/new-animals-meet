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

class PostFeedVC: FeedViewController {
    
    var textView: UITextView!
    var user: UserModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        paginated = true
    }
    
    override func fetchItems(from: Int, count: Int) -> Promise<[MediaModel]> {
        return unready.promiseReady.then {
            Api.instance.get("/user/\(self.user.id!)/posts/\(from)").then { JSON -> [MediaModel] in
                JSON["posts"].arrayValue.map { MediaModel(fromJSON: $0) }
            }
        }
    }
}
