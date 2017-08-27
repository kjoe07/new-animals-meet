//
//  ConversationViewController.swift
//  AnimalsMeet
//
//  Created by Adrien Morel on 07/12/2016.
//  Copyright © 2016 AnimalsMeet. All rights reserved.
//

import UIKit
import NMessenger
import AsyncDisplayKit
import SwiftyJSON
import Kingfisher

class ConversationViewController: NMessengerViewController {
   
   var currentGroup = MessageGroup()
   var shouldSend = true
   var conversationHasLoaded = false
   var iTextedLast: Bool!
   var conversation: ConversationModel!
   var uglyConversationReloadingTimer: Timer?
   
   // TODO: use the library with nice time displays
   func putTimestamp(date: Date) {
      
      let formatter = DateFormatter()
      formatter.dateStyle = .medium
      formatter.timeStyle = .short
      
      let dateString = date.localizedString
      
      let messageTimestamp = MessageSentIndicator()
      messageTimestamp.messageSentText = dateString
      addMessageToMessenger(messageTimestamp)
   }
   
   func receivedText(message: String) {
      
      let textContent = TextContentNode(textMessageString: message)
      let newMessage = MessageNode(content: textContent)
      
      if iTextedLast {
         currentGroup = MessageGroup()
         iTextedLast = false
         messengerView.addMessage(currentGroup, scrollsToMessage: true)
      }
      
      currentGroup.addMessageToGroup(newMessage, completion: nil)
      currentGroup.avatarNode = makeFriendAvatar()
      currentGroup.currentViewController = self
      currentGroup.cellPadding = self.messagePadding
   }
   
   func makeFriendAvatar() -> ASImageNode {
      
      let ir = ASImageNode()
      ir.backgroundColor = UIColor.lightGray
      ir.preferredFrameSize = CGSize(width: 30, height: 30)
      ir.layer.cornerRadius = 15
      ir.clipsToBounds = true
      ir.image = UIImage(named: "anonymous")
      
      if let correspondentAvatar = conversation.recipient?.image {
         let avatar = UIImageView()
         avatar.kf.setImage(with: correspondentAvatar,
                            placeholder: nil,
                            options: [.transition(.fade(1))],
                            progressBlock: nil,
                            completionHandler: nil);
         ir.image = avatar.image
      }
      return ir
   }
   
   var messageDate: Date!
   var newMessageDate: Date!
   
   func isAlreadyShown(_ msg: String) {
      
   }
   
   override func sendText(_ text: String, isIncomingMessage: Bool) -> GeneralMessengerCell {
      let textContent = TextContentNode(textMessageString: text, currentViewController: self, bubbleConfiguration: sharedBubbleConfiguration)
      
      let newMessage = MessageNode(content: textContent)
      newMessage.cellPadding = messagePadding
      newMessage.currentViewController = self
      
      if currentGroup.isIncomingMessage == !isIncomingMessage {
         
         if messageDate != nil {
            putTimestamp(date: messageDate)
            messageDate = nil
         } else {
            putTimestamp(date: Date())
         }
         
         currentGroup = MessageGroup()
         if isIncomingMessage {
            currentGroup.avatarNode = makeFriendAvatar()
         }
         
         currentGroup.isIncomingMessage = isIncomingMessage
         messengerView.addMessageToMessageGroup(newMessage, messageGroup: self.currentGroup, scrollsToLastMessage: false)
         self.messengerView.addMessage(self.currentGroup, scrollsToMessage: true, withAnimation: isIncomingMessage ? .left : .right)
      } else {
         self.messengerView.addMessageToMessageGroup(newMessage, messageGroup: self.currentGroup, scrollsToLastMessage: true)
      }
      
      if !isIncomingMessage && shouldSend {
         conversation.send(msg: text).catch(execute: App.showRequestFailure)
      }
      
      return newMessage
   }
   
   override func viewWillAppear(_ animated: Bool) {
      (self.tabBarController as? AnimalTabBarController)?.centerButton.isHidden = true
   }
   
   override func viewWillDisappear(_ animated: Bool) {
      (self.tabBarController as? AnimalTabBarController)?.centerButton.isHidden = false
   }
   
   func refreshConv() {
      print("refreshing")
      let pageSize = 10
      let page = conversation.messagesFixme.count / pageSize + 1
      
      Api.instance.get("/messaging/\(conversation.recipient.id!)/\(page)")
         .then { json -> Void in
            let messages = json["conversation"].arrayValue.map { msg in
               MessageModel(fromJSON: msg)
            }
            
            let messageCount = self.conversation.messagesFixme.count
            let lastMessage = self.conversation.messagesFixme.last
            
            for m in messages {
               
               let conv = self.conversation!
               
               if messageCount == 0 || m.id > lastMessage!.id {
                  if !self.conversationHasLoaded || m.senderId != App.instance.userModel.id {
                     conv.messagesFixme.append(m)
                     self.shouldSend = false
                     self.messageDate = m.date
                     _ = self.sendText(m.content, isIncomingMessage: m.senderId != App.instance.userModel.id)
                     print("added item")
                     self.shouldSend = true
                  }
               } 
            }
            
            self.conversationHasLoaded = true
         }.catch { err in
      }
   }
   
   func addMessagesInConv() {
      
      self.shouldSend = false
      print("willl add \(conversation.messagesFixme.count) messages")
      for m in conversation.messagesFixme {
         _ = self.sendText(m.content, isIncomingMessage: m.senderId != App.instance.userModel.id)
         print("added message in conversation")
      }
      self.shouldSend = true
   }
   
   override func viewDidDisappear(_ animated: Bool) {
      uglyConversationReloadingTimer?.invalidate()
   }
   
   override func viewDidLoad() {
      super.viewDidLoad()
      
      let showProfile = UIBarButtonItem(title: "Voir le profil", style: .plain, target: self, action: #selector(showRecipientProfile))
      self.navigationItem.rightBarButtonItem = showProfile
      
      (self.inputBarView as! NMessengerBarView).inputTextViewPlaceholder = "Message..."
      
      uglyConversationReloadingTimer = Timer.scheduledTimer(timeInterval: 2.0, target: self, selector: #selector(self.refreshConv), userInfo: nil, repeats: true);
      self.navigationItem.title = conversation.recipient.name
      self.automaticallyAdjustsScrollViewInsets = false
      
      guard let recipient = self.conversation.recipient else { return }
      self.conversation = ConversationModel(user: recipient)
      
//      self.addMessagesInConv()
      self.refreshConv()
   }
   
   func showRecipientProfile() {
      let recipientProfileVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "AnimalVC") as! AnimalVC
      recipientProfileVC.shouldHideNavigationBar = false
      recipientProfileVC.user = conversation.recipient
      _ = Api.instance.get("/user/\(conversation.recipient.id!)/animals")
         .then { json -> [AnimalModel] in
            json["animals"].arrayValue.map {AnimalModel(fromJSON: $0) }
         }
         .then { animals -> Void in
            recipientProfileVC.animal = animals[0]
            self.navigationController?.pushViewController(recipientProfileVC, animated: true)
      }
   }
}
