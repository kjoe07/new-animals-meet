//
//  NotificationModel.swift
//  AnimalsMeet
//
//  Created by gwendal lasson on 04/05/2017.
//  Copyright © 2017 AnimalsMeet. All rights reserved.
//

import Foundation
import SwiftyJSON

class NotificationModel {
    
    var updatedAt: Date!
    var type: Int!
    var user: UserModel!
    var animal: AnimalModel?
    
    init(fromJSON json: JSON) {
        
        var i = 0
        user = UserModel(fromJSON: json[i])
        
        if !json[1]["created_at"].exists() {
            i += 1
            animal = AnimalModel(fromJSON: json[i])
        }
        
        i += 1
        let jsonNotif = json[i]
        type = jsonNotif["code_action"].intValue
    }
}
