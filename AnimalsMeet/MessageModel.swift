//
//  MessageModel.swift
//  AnimalsMeet
//
//  Created by Adrien morel on 01/06/2017.
//  Copyright © 2017 AnimalsMeet. All rights reserved.
//

import Foundation
import SwiftyJSON

class MessageModel {
    
    var id: Int!
    var content: String!
    var senderId: Int!
    var date: Date!
    
    init(fromJSON json: JSON) {
        
        content = json["content"].stringValue
        senderId = json["user_id"].intValue
        id = json["id"].intValue
        date = Date(fromString: json["updated_at"].stringValue, format: .custom("yyyy-MM-dd'T'HH:mm:ss.SSSXXXXX"))
    }
}
