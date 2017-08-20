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
      let notification = json["notification"]

      user = UserModel(fromJSON: notification["user_sender"])
      let animalJSON = notification["animal_sender"]
      
      if animalJSON.exists() && animalJSON.null == nil {
         animal = AnimalModel(fromJSON: animalJSON)
      }
      
      type = notification["code_action"].intValue
      
      if let dateStr = notification["created_at"].string {
         updatedAt = Date(fromString: dateStr, format: .isoDateTimeMilliSec)
      }
      else {
         updatedAt = Date()
      }
   }
}
