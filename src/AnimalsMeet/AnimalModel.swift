//
//  AnimalModel.swift
//  AnimalsMeet
//
//  Created by Sacha IFRAH on 18/10/2016.
//  Copyright © 2016 AnimalsMeet. All rights reserved.
//

import Foundation
import SwiftyJSON
import PromiseKit

class AnimalModel {
   
   enum Sex {
      case male
      case female
      case transgender
      
      static func fromString(_ str: String) -> Sex {
         switch str {
         case "f":
            return .female
         case "m":
            return .male
         default:
            return .transgender
         }
      }
      
      func toString() -> String {
         switch self {
         case .male:
            return "m"
         case .female:
            return "f"
         default:
            return "t"
         }
      }
   }
   
   var id: Int!
   var type: String!
   var name: String!
   var sex: Sex!
   var year: String!
   var breed: Int!
   var loof: Bool!
   var heat: Bool?
   var mediaList: [MediaModel]?
   var distance: Int! // Kilometers
   var ownerId: Int!
   var profilePicMediaId: Int?
   var profilePicUrl: URL {
      if let id = profilePicMediaId {
         return App.getImageUrlFromMediaId(id)
      }
      return URL(string: "http://5938817ba700c46cfb5e8afe.golpher-alba-38686.netlify.com/anonymous.png")!
   }
   
   init() {
   }
   
   init(fromJSON json: JSON, distance: Int = 0) {
      id =      json["id"].intValue
      name =    json["name"].stringValue
      type =    json["type_animal"].stringValue
      sex =     Sex.fromString(json["sex"].stringValue)
      year =    json["birthday"].stringValue
      breed =   json["breed_id"].intValue
      loof =    json["lof"].boolValue
      heat =    json["heat"].bool
      profilePicMediaId = Int(json["profil_media"].stringValue)
      ownerId = json["user_id"].intValue
      self.distance = distance // TODO: check if necessary
   }
   
   static func from(id: Int) -> Promise<AnimalModel> {
      
      return Api.instance.get("/animals/\(id)")
         .then { JSON -> AnimalModel in
            let animal = AnimalModel(fromJSON: JSON, distance: 0)
            /*
             animal.mediaList = JSON["medias"].arrayValue.map {
             // return MediaModel.from(json: $0) TODO: reverse me
             }
             */
            return animal
      }
   }
   
   func breedName() -> String {
      return App.instance.breeds[breed].nameFr
   }
   
   func serializeToDict() -> Dictionary<String, Any> {
      
      var dict = ["animal": [
         "type_animal": type,
         "name": name,
         "lof": loof,
         "birthday": year,
         "breed_id": breed,
         "sex": sex.toString(),
         "heat": heat ?? false,
         ]
      ]
      
      if let id = profilePicMediaId {
         dict["animal"]!["profil_media"] = id
      }
      return dict
   }
   
   func sync() -> Promise<JSON> {
      return Api.instance.put("/animals/\(id!)", withParams: serializeToDict())
   }
   
   func syncCreate() -> Promise<JSON> {
      return Api.instance.post("/animals", withParams: serializeToDict())
   }
   
   func syncDelete() -> Promise<JSON> {
      return Api.instance.delete("/animals/\(id!)")
   }
   
   func isMine() -> Bool {
      return App.instance.userModel.animals!.contains { $0.id == self.id }
   }
}
