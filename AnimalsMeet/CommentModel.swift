//
//  NotificationModel.swift
//  AnimalsMeet
//
//  Created by gwendal lasson on 04/05/2017.
//  Copyright © 2017 AnimalsMeet. All rights reserved.
//

import Foundation
import SwiftyJSON

class CommentModel {
    
    var author: UserModel!
    var id: Int!
    var text: String!
    var likeCount: Int!
    var iLiked = false
    
    init() {}
    
    init(fromJSON json: JSON) {
        
        author = UserModel(fromJSON: json["author"])
        id = json["id"].intValue
        text = json["text"].stringValue
        likeCount = json["likeCount"].intValue
        iLiked = json["i_liked"].boolValue
    }
}
