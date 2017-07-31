//
//  MediaModel.swift
//  AnimalsMeet
//
//  Created by Sacha IFRAH on 24/10/2016.
//  Copyright © 2016 AnimalsMeet. All rights reserved.
//

import Foundation
import SwiftyJSON
import PromiseKit
import Alamofire

class MediaModel {
    
    var id: Int! {
        didSet {
            self.url = URL(string: "\(Api.instance.serverUrl)/media/\(id!)")!
        }
    }
    var url: URL!
    var isLiked = false
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
        
        for like in json["like"].arrayValue {
            likeCount += 1
            if like["user_id"].intValue == App.instance.userModel.id {
                isLiked = true
            }
        }
        
        likeCount = json["like"].count
        animal = AnimalModel(fromJSON: json["animal"])
    }
    
    func getRaw(id: String) -> Promise<JSON> {
        return Api.instance.get("/media/\(id)")
    }
    
    func callForDelete() -> Promise<JSON> {
        return Api.instance.get("/delete_my_media/\(id!)")
    }
    
    func callForCreate() -> Promise<JSON> {
        
        var id = -1
        if animal != nil {
            id = animal.id
        }
        var mediaObj: Parameters = ["file64": rawData, "idAnimal": "\(id)"]
        if let legend = self.description {
            mediaObj["legend"] = legend
        }
        
        let parameters: Parameters = ["media" : mediaObj]
        return Api.instance.post("/media", withParams: parameters)
    }

    func callForLike(fromAnimal: Int) -> Promise<JSON> {
        let parameters = ["like[media]" : "\(id ?? 0)", "like[animal]": "\(fromAnimal)"]
        return Api.instance.post("/like", withParams: parameters)
    }
    
    func callForUnlike() -> Promise<JSON> {
        let parameters = ["like" : ["media" : "\(id ?? 0)", "like[animal]": "\(App.instance.getSelectedAnimal().id!)"]]
        return Api.instance.delete("/like", withParams: parameters)
    }
    
    func comment(content: String) -> Promise<JSON> {
        return Api.instance.post("/media/\(id!)/create_comment", withParams: ["content": content])
    }
}
