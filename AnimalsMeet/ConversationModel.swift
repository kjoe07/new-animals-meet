//
//  ChatModel.swift
//  AnimalsMeet
//
//  Created by Sacha IFRAH on 24/10/2016.
//  Copyright © 2016 AnimalsMeet. All rights reserved.
//

import Alamofire
import Foundation
import SwiftyJSON
import PromiseKit

class ConversationModel {
    
    var recipient: UserModel!
    var messages: [String]?
    var messagesFixme = [MessageModel]()
    var date: Date!
    
    init() {
    }
    
    init(user: UserModel) {
        recipient = user
    }
    
    init(json: JSON) {
        
        let recipient = UserModel()
        
        let conversationData = json[0]
        recipient.id = conversationData["id"].intValue
        recipient.image = URL(string: conversationData["image"].stringValue)
        recipient.nickname = conversationData["nickname"].stringValue
        recipient.email = conversationData["email"].stringValue
        
        let firstMsg = json[1]
        messages = [firstMsg["content"].stringValue]
        date = Date(fromString: firstMsg["updated_at"].stringValue, format: .custom("yyyy-MM-dd'T'HH:mm:ss.SSSXXXXX"))
        self.recipient = recipient
    }
    
    func send(msg: String) -> Promise<JSON> {
        
        let parameters = ["messaging[correspondent]" : String(recipient.id!), "messaging[content]": msg]
        return Api.instance.request("/messaging", withParams: parameters, method: .post, encoding: URLEncoding.default)
        
    }
    
    func callForRemove() -> Promise<JSON> {
        return Api.instance.delete("messaging/\(recipient.id!)")
    }
    
    func fetch(count: Int) -> Promise<Void> {
        return Api.instance.get("messaging/\(recipient.id!)")
            .then { JSON -> () in
                let messagesJSON = JSON["conversation"].arrayValue
                self.messages = messagesJSON.map { $0.stringValue }
        }
    }
}
