//
//  MessageModel.swift
//  AnimalsMeet
//
//  Created by Adrien morel on 01/06/2017.
//  Copyright © 2017 AnimalsMeet. All rights reserved.
//

import Foundation
import SwiftyJSON
import MessageKit
class MessageModel : MessageType{
    
	//var id: Int!
	//var content: String!
	//var senderId: Int!
	//var date: Date!
	var messageId: String
	var sender: Sender
	var sentDate: Date
	var data: MessageData
    
    init(fromJSON json: JSON) {
		self.messageId = json["id"].stringValue
		let mysender:Sender = Sender(id: json["user_id"].stringValue, displayName: "")
		self.sender = mysender
		self.sentDate = Date(fromString: json["updated_at"].stringValue, format: .custom("yyyy-MM-dd'T'HH:mm:ss.SSSXXXXX"))!
		//self.data = .text(json["content"].stringValue)
		let msg9String = json["content"].stringValue.decodeEmoji
		let msg9Text = NSString(string: msg9String)
		let msg9AttributedText = NSMutableAttributedString(string: String(msg9Text))
		print("el valor del mensaje: \(msg9String)")
		self.data = .attributedText(msg9AttributedText)
		//self.data = self.data.decodeEmoji
		//content = json["content"].stringValue
		//senderId = json["user_id"].intValue
		//id = json["id"].intValue
		//date = Date(fromString: json["updated_at"].stringValue, format: .custom("yyyy-MM-dd'T'HH:mm:ss.SSSXXXXX"))
    }

	
}
