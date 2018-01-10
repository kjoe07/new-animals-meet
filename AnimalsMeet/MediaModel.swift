//
//  MediaModel.swift
//  AnimalsMeet
//
//  Created by Sacha IFRAH on 24/10/2016.
//  Copyright © 2016 AnimalsMeet. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
import PromiseKit

extension NSNotification.Name {
   
}

class MediaModel {
   static let MediaLikedNotification = NSNotification.Name("MediaLiked")
   static let MediaKey = "Media"
   
   var id: Int! {
      didSet {
         self.url = URL(string: "\(Api.instance.serverUrl)/media/\(id!)")!
      }
   }
   var url: URL!
   var isLiked = false {
      didSet {
         NotificationCenter.default.post(
            name: MediaModel.MediaLikedNotification,
            object: nil,
            userInfo: [MediaModel.MediaKey: self]
         )
      }
   }
   var likeCount = 0
   var rawData: String!
   var width = 400
   var height = 300
   var updatedAt: Date!
   var animal: AnimalModel!
   var author: UserModel!
   var description: String?
   var isText: Bool!
   var contentText: String!
    //var taggedUser: [String]!
   
   init() {
   }
   
   init(fromJSON json: JSON) {
      height = json["dim_height"].intValue
      author = UserModel(fromJSON: json["user_obj"])
      width = json["dim_width"].intValue
      updatedAt = Date(fromString: json["updated_at"].stringValue, format: .custom("yyyy-MM-dd'T'HH:mm:ss.SSSXXXXX"))
      description = json["legend"].stringValue
      isText = json["isText"].boolValue
      contentText = json["contentText"].stringValue
      
      defer {
         id = json["id"].intValue
      }
      
	for like in json["like"].arrayValue { //TODO: - check like format in json response -
         likeCount += 1
         if like["user_id"].intValue == App.instance.userModel.id {
            isLiked = true
         }
      }
      
      likeCount = json["like"].count
      animal = AnimalModel(fromJSON: json["animal"])
      //taggedUser = [String]()
   }
   
   func getRaw(id: String) -> Promise<JSON> {
      return Api.instance.get("/media/\(id)")
   }
   
   func callForDelete() -> Promise<JSON> {
      return Api.instance.get("/delete_my_media/\(id!)")
   }
   
    func callForCreate(taggedUser:[String]!) -> Promise<JSON> {
      
      var id = -1
      if animal != nil {
         id = animal.id
      }
        var mediaObj: Parameters = ["file64": rawData, "idAnimal": "\(id)"]
      if let legend = self.description {
         mediaObj["legend"] = legend
      }
      
      let parameters: Parameters = ["media" : mediaObj,"users": taggedUser ?? ""]
      return Api.instance.post("/media", withParams: parameters)
   }
   
   func callForLike(fromAnimal: Int) -> Promise<JSON> {
      let parameters = ["like[media]" : "\(id ?? 0)", "like[animal]": "\(fromAnimal)"]
      return Api.instance.post("/like", withParams: parameters)
   }
   
   func callForUnlike() -> Promise<JSON> {
      let parameters = ["like" : ["media" : "\(id ?? 0)", "animal": "\(App.instance.getSelectedAnimal().id!)"]]
      return Api.instance.delete("/like", withParams: parameters)
   }
   
   func comment(content: String) -> Promise<JSON> {
    //let new_content = encode_emoji(content)
      return Api.instance.post("/media/\(id!)/create_comment", withParams: ["content": content.encodeEmoji])
   }
}
extension MediaModel{
    func encode_emoji(_ s: String) -> String {
        let data = s.data(using: .nonLossyASCII, allowLossyConversion: true)!
        return String(data: data, encoding: .utf8)!
    }
    func decode_emoji(_ s: String) -> String? {
        let data = s.data(using: .utf8)!
        return String(data: data, encoding: .nonLossyASCII)
    }
}

