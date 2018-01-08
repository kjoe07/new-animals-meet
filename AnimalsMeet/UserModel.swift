//
//  User.swift
//  AnimalsMeet
//
//  Created by Sacha IFRAH on 04/10/2016.
//  Copyright © 2016 AnimalsMeet. All rights reserved.
//

import SwiftyJSON
import Foundation
import PromiseKit

class UserModel {
   
   var provider: String! // (email or facebook)
   var name: String?
   var nickname: String?
	var id: Int!/*{
		didSet {
			print("estableciendo la imagen a: \(Api.instance.serverUrl)/media/\(id!)")
			self.image = URL(string: "\(Api.instance.serverUrl)/media/\(id!)")!
		}
	}*/
   var uid: String!
   var image: URL?
   var email: String!
   var animals: [AnimalModel]?
   var isMe: Bool {
      return id == App.instance.userModel.id
   }
   var followingCount: Int!
   var followersCount: Int!
   var followers: [UserModel]!
   var suivis: [UserModel]!
   var likeCount: Int!
   
   init() {
   }
   
   init(fromJSON JSON: JSON) {
      
      
      var result = JSON
      if result["result"].null == nil {
         result = result["result"]
      } else if result["user"].null == nil {
         result = result["user"]
      }
    if result["animals"].null != nil {
        animals = result["animal"].arrayValue.map{ AnimalModel(fromJSON : $0)}
    }
    
      followers = result["followers"].arrayValue.map { UserModel(fromJSON: $0) }
	  suivis = result["followings"].arrayValue.map { UserModel(fromJSON: $0) }
      provider = result["provider"].stringValue
      nickname = result["nickname"].stringValue.replacingOccurrences(of: " ", with: "").lowercased()
      name = result["name"].string
      id = result["id"].intValue
      uid = result["uid"].stringValue
      let imageURI = result["image"].string
      if let imageURI = imageURI, imageURI != "", imageURI != "<null>" { //modified in case image is ""Url.init explote
        /*print("la imagen \(imageURI)")
         image = URL(string: imageURI)
         // WORKAROUND: avoid problem with fixed address being returned by the server
         let path = image!.path
         let baseUrl = URL(string: Api.instance.serverUrl)
         image = URL(string: path, relativeTo: baseUrl)*/
		image = URL(string: "\(Api.instance.serverUrl)/media/\(imageURI)")
      } else {
         image = URL(string: "http://5943f28e6f4c50095616f995.golpher-alba-38686.netlify.com/anonymous.png")
      }
      
      let stats = result["stats"]
      followersCount = stats["stats_followers"].intValue
      followingCount = stats["stats_following"].intValue
      likeCount = stats["stats_like"].intValue
   }
   
   static func getProfilUser() -> Promise<UserModel> {
      
      return Api.instance.get("/my/profil", withParams: [:])
         .then { JSON in UserModel(fromJSON: JSON) }
   }
   
   static func callForCreate(email: String, password: String) -> Promise<Void> {
      let parameters = ["email": email, "password": password];
      return Api.instance.post("/auth", withParams: parameters).then { _ -> () in }
   }
   
   static func updateChanges(name: String, nickname: String) -> Promise<JSON> {
      let parameters = ["user": [
         "name": name,
         "nickname": nickname,
         ]
      ]
    
      return Api.instance.put("/user", withParams: parameters)
   }
   
   func isFriend() -> Bool {
      return followers.contains { App.instance.userModel.id == $0.id }
   }
   
   func friend() {
      followers.append(App.instance.userModel)
   }
   
   func unfriend() {
      if let idx = followers.index(where: { $0.id == App.instance.userModel.id }) {
         followers.remove(at: idx)
      }
   }
}
