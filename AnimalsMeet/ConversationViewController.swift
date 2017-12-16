//
//  ConversationViewController.swift
//  AnimalsMeet
//
//  Created by Adrien Morel on 07/12/2016.
//  Copyright © 2016 AnimalsMeet. All rights reserved.
//

import UIKit
//import NMessenger
import AsyncDisplayKit
import SwiftyJSON
import Kingfisher
import MessageKit
class ConversationViewController: MessagesViewController/*NMessengerViewController*/ {
	var messageList: [MessageModel] = []
	var pageN :Int!
	var recipientId: Int!
	var conversation: ConversationModel!
	var lastid: Int!
	override func viewDidLoad() {
		super.viewDidLoad()
		
		let showProfile = UIBarButtonItem(title: "Voir le profil", style: .plain, target: self, action: #selector(showRecipientProfile))
		self.navigationItem.rightBarButtonItem = showProfile
		
		//(self.inputBarView as! NMessengerBarView).inputTextViewPlaceholder = "Message..."
		
		let timer = Timer.scheduledTimer(timeInterval: 2.0, target: self, selector: #selector(self.refreshConv), userInfo: nil, repeats: true);
		//self.navigationItem.title = conversation.recipient.name
		self.automaticallyAdjustsScrollViewInsets = false
		automaticallyAdjustsScrollViewInsets = false
		self.refreshConv()
		messagesCollectionView.messagesDataSource = self
		messagesCollectionView.messagesLayoutDelegate = self
		messagesCollectionView.messagesDisplayDelegate = self
		messagesCollectionView.messageCellDelegate = self
		messageInputBar.delegate = self
	}
	override func viewWillAppear(_ animated: Bool) {
		(self.tabBarController as? AnimalTabBarController)?.centerButton.isHidden = true
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		(self.tabBarController as? AnimalTabBarController)?.centerButton.isHidden = false
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
	func refreshConv() {
		print("refreshing")
		let pageSize = 10
		var page = 1
		/*if self.pageN != nil {
		page = self.pageN
		}else {
		page = conversation.messagesFixme.count / pageSize + 1
		}*/
		if self.pageN == nil {
			self.pageN = 1
		}
		Api.instance.get("/messaging/\(conversation.recipient.id!)/\(self.pageN!)"/**/)
			.then { json -> Void in
				/*if self.firstload {
					self.firstload = false
				}//&& self.pageN ==
				*/
				let messages = json["conversation"].arrayValue.map { msg in
					MessageModel(fromJSON: msg)
				}
				//self.conversation.messagesFixme += messages
				if self.pageN < json["total_page"].intValue{
					self.pageN! += 1
					//self.refreshConv()
					
				}
				
				if self.lastid == nil {
					self.lastid = -1
				}
				print("lastid value: \(self.lastid)")
				if messages.count > 0 {
					print("es mayor que 0")
					if Int((messages.first?.messageId)!)! > self.lastid {
						print("adding to messageList")
						self.messageList += messages
						self.lastid = Int((self.messageList.last?.messageId)!)
						self.messagesCollectionView.reloadData()
					}
				}
				/*
				/*else{
				self.uglyConversationReloadingTimer = nil
				self.uglyConversationReloadingTimer = Timer.scheduledTimer(timeInterval: 5.0, target: self, selector: #selector(self.refreshConv), userInfo: nil, repeats: true);
				
				}*/
				
				let messageCount = self.conversation.messagesFixme.count
				let lastMessage = self.conversation.messagesFixme.first //self.conversation.messagesFixme.first//
				print("el ultimo Id \(String(describing: self.lastid))")/**/
				for m in messages {
					//let conv = self.conversation!
					
					/*if messageCount == 0 || m.id > lastMessage!.id {
					print("contando mensajes \(messageCount)")
					print("el valor de la  iteracion actual: \(m.id)")
					if !self.conversationHasLoaded || m.senderId != App.instance.userModel.id {
					print("el mensaje no es mio x lo que añado a los mensajes")
					conv.messagesFixme.append(m)
					self.shouldSend = false
					self.messageDate = m.date
					_ = self.sendText(m.content, isIncomingMessage: m.senderId != App.instance.userModel.id)
					print("added item")
					self.shouldSend = true
					}
					} */
					if messageCount == 0 && !self.conversationHasLoaded{
						//conv.messagesFixme.append(m)
						self.conversation.messagesFixme.append(m) //insert(m, at: 0) //
						self.shouldSend = false
						self.messageDate = m.date
						print("entrante o no: \(m.senderId != App.instance.userModel.id)")
						print("el id de usuario:\(App.instance.userModel.id)")
						_ = self.sendText(m.content, isIncomingMessage: m.senderId != App.instance.userModel.id)
						print("added All items in Conversation ")
						self.shouldSend = true
						self.lastid = m.id
						
					}else{
						print("m.id \(String(describing: m.id)) > lastmesage.id \(String(describing: self.lastid))")
						if m.id > (self.lastid)! { //&& m.senderId != App.instance.userModel.id
							print("debo Añadir un mensaje nuevo")
							print("entrante o no: \(m.senderId != App.instance.userModel.id)")
							self.conversation.messagesFixme.append(m) //insert(m, at: 0) //append(m)
							self.shouldSend = false
							self.messageDate = m.date
							_ = self.sendText(m.content, isIncomingMessage: m.senderId != App.instance.userModel.id)
							print("added new items in Conversation")
							self.shouldSend = true
						}
					}
				}
				self.lastid = self.conversation.messagesFixme.last?.id
				if self.pageN == json["total_page"].intValue{
					self.conversationHasLoaded = true
				}else{
					
				}
				self.conversationHasLoaded = self.pageN == json["total_page"].intValue ? true : false
				
				// =  self.conversation.messagesFixme.count > 0 ? true : false //true*/
			}.catch { err in
		}
	}

   /*
   var currentGroup = MessageGroup()
   var shouldSend = true
   var conversationHasLoaded = false
   var iTextedLast: Bool!
   var conversation: ConversationModel!
   var uglyConversationReloadingTimer: Timer?
    var lastid : Int!
    var pageN: Int!
    var firstload = true
    var lastMessageGroup:MessageGroup? = nil
	var timerValue: TimeInterval = 15.0
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
   
 /*  override func sendText(_ text: String, isIncomingMessage: Bool) -> GeneralMessengerCell {

    print("texto a Añadir: \(text)")
    print("entrante o no : \(isIncomingMessage)")
      let textContent = TextContentNode(textMessageString: text.decodeEmoji, currentViewController: self, bubbleConfiguration: sharedBubbleConfiguration)
      
      let newMessage = MessageNode(content: textContent)
      newMessage.cellPadding = messagePadding
      newMessage.currentViewController = self
      print(currentGroup.isIncomingMessage)
      if currentGroup.isIncomingMessage == !isIncomingMessage {
        print("supongo que sea mensaje propio")
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
        print("mensaje entrante")
         self.messengerView.addMessageToMessageGroup(newMessage, messageGroup: self.currentGroup, scrollsToLastMessage: true) //true
      }
      
      if !isIncomingMessage && shouldSend {
        print("enviando mensaje")
         conversation.send(msg: text).catch(execute: App.showRequestFailure)
      }
      
      return newMessage
   }*/
	override func sendText(_ text: String, isIncomingMessage: Bool) -> GeneralMessengerCell {
		print(isIncomingMessage)
		
		//create a new text message
		let textContent = TextContentNode(textMessageString: !isIncomingMessage ? text : text.decodeEmoji, currentViewController: self, bubbleConfiguration: self.sharedBubbleConfiguration)
		let newMessage = MessageNode(content: textContent)
		newMessage.cellPadding = messagePadding
		newMessage.currentViewController = self
		
		//add message to correct group
		if isIncomingMessage{ //(self.senderSegmentedControl.selectedSegmentIndex == 0) { //incoming
			print("texto a añadir en sendText: \(text.decodeEmoji)")
			self.postText(newMessage, isIncomingMessage: true)
		} else { //outgoing
			self.postText(newMessage, isIncomingMessage: false)
			if conversationHasLoaded {
				print("mensaje a enviar\(text.encodeEmoji)")
				_ = conversation.send(msg: text.encodeEmoji)
			}
		}
		return newMessage
	}
	func postText(_ message: MessageNode, isIncomingMessage: Bool) {
		if self.lastMessageGroup == nil || self.lastMessageGroup?.isIncomingMessage == !isIncomingMessage {
			self.lastMessageGroup = self.createMessageGroup()
			print("el ultimo mensaje es nil")
			//add avatar if incoming message
			if isIncomingMessage {
				self.lastMessageGroup?.avatarNode = self.makeFriendAvatar()//self.createAvatar()
			}
			
			self.lastMessageGroup!.isIncomingMessage = isIncomingMessage
			self.messengerView.addMessageToMessageGroup(message, messageGroup: self.lastMessageGroup!, scrollsToLastMessage: false)
			self.messengerView.addMessage(self.lastMessageGroup!, scrollsToMessage: true, withAnimation: isIncomingMessage ? .left : .right)
			
		} else {
			print("el contenido del mensaje: \(String(describing: (message.contentNode as! TextContentNode).textMessageString))")
			self.messengerView.addMessageToMessageGroup(message, messageGroup: self.lastMessageGroup!, scrollsToLastMessage: true)
		}
	}
	func createMessageGroup()->MessageGroup {
		let newMessageGroup = MessageGroup()
		newMessageGroup.currentViewController = self
		newMessageGroup.cellPadding = self.messagePadding
		return newMessageGroup
	}
	func createAvatar()->ASImageNode {
		let avatar = ASImageNode()
		avatar.backgroundColor = UIColor.lightGray
		avatar.preferredFrameSize = CGSize(width: 20, height: 20)
		avatar.layer.cornerRadius = 10
		return avatar
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
    var page = 1
    /*if self.pageN != nil {
        page = self.pageN
    }else {
        page = conversation.messagesFixme.count / pageSize + 1
    }*/
    if self.pageN == nil {
        self.pageN = 1
    }
      Api.instance.get("/messaging/\(conversation.recipient.id!)/\(self.pageN!)"/**/)
         .then { json -> Void in
            if self.firstload {                
                self.firstload = false
            }//&& self.pageN ==
			
            let messages = json["conversation"].arrayValue.map { msg in
               MessageModel(fromJSON: msg)
            }
			//self.conversation.messagesFixme += messages
			if self.pageN < json["total_page"].intValue{
				self.pageN! += 1
				//self.refreshConv()
				
			}/*else{
				self.uglyConversationReloadingTimer = nil
				self.uglyConversationReloadingTimer = Timer.scheduledTimer(timeInterval: 5.0, target: self, selector: #selector(self.refreshConv), userInfo: nil, repeats: true);
				
			}*/
			
            let messageCount = self.conversation.messagesFixme.count
            let lastMessage = self.conversation.messagesFixme.first //self.conversation.messagesFixme.first//
            print("el ultimo Id \(String(describing: self.lastid))")/**/
            for m in messages {
               //let conv = self.conversation!
               
               /*if messageCount == 0 || m.id > lastMessage!.id {
                print("contando mensajes \(messageCount)")
                print("el valor de la  iteracion actual: \(m.id)")
                  if !self.conversationHasLoaded || m.senderId != App.instance.userModel.id {
                    print("el mensaje no es mio x lo que añado a los mensajes")
                     conv.messagesFixme.append(m)
                     self.shouldSend = false
                     self.messageDate = m.date
                     _ = self.sendText(m.content, isIncomingMessage: m.senderId != App.instance.userModel.id)
                     print("added item")
                     self.shouldSend = true
                  }
               } */
                if messageCount == 0 && !self.conversationHasLoaded{
                    //conv.messagesFixme.append(m)
                    self.conversation.messagesFixme.append(m) //insert(m, at: 0) //
                    self.shouldSend = false
                    self.messageDate = m.date
					print("entrante o no: \(m.senderId != App.instance.userModel.id)")
					print("el id de usuario:\(App.instance.userModel.id)")
                    _ = self.sendText(m.content, isIncomingMessage: m.senderId != App.instance.userModel.id)
                    print("added All items in Conversation ")
                    self.shouldSend = true
                    self.lastid = m.id
                    
                }else{
					print("m.id \(String(describing: m.id)) > lastmesage.id \(String(describing: self.lastid))")
					if m.id > (self.lastid)! { //&& m.senderId != App.instance.userModel.id
                        print("debo Añadir un mensaje nuevo")
						print("entrante o no: \(m.senderId != App.instance.userModel.id)")
                        self.conversation.messagesFixme.append(m) //insert(m, at: 0) //append(m)
                        self.shouldSend = false
                        self.messageDate = m.date
                        _ = self.sendText(m.content, isIncomingMessage: m.senderId != App.instance.userModel.id)
                        print("added new items in Conversation")
                        self.shouldSend = true
                    }
                }
            }
            self.lastid = self.conversation.messagesFixme.last?.id
			if self.pageN == json["total_page"].intValue{
				self.conversationHasLoaded = true
			}else{
				
			}
			self.conversationHasLoaded = self.pageN == json["total_page"].intValue ? true : false
            
			// =  self.conversation.messagesFixme.count > 0 ? true : false //true
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
      
      uglyConversationReloadingTimer = Timer.scheduledTimer(timeInterval: timerValue, target: self, selector: #selector(self.refreshConv), userInfo: nil, repeats: true);
      self.navigationItem.title = conversation.recipient.name
      self.automaticallyAdjustsScrollViewInsets = false
      
      guard let recipient = self.conversation.recipient else { return }
      self.conversation = ConversationModel(user: recipient)
      var messageGroups = [MessageGroup]()
      self.messengerView.addMessages(messageGroups, scrollsToMessage: false)
      self.messengerView.scrollToLastMessage(animated: false)
      self.lastMessageGroup = messageGroups.last
    //END BOOTSTRAPPING OF MESSAGES
    
    automaticallyAdjustsScrollViewInsets = false
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
   }*/
}
extension ConversationViewController: MessagesDataSource {
	
	func currentSender() -> Sender {
		return  Sender(id: String(App.instance.userModel.id), displayName: App.instance.userModel.nickname!) //self.conversation.recipient.nickname//SampleData().getCurrentSender()
	}
	
	func numberOfMessages(in messagesCollectionView: MessagesCollectionView) -> Int {
		print("cantidad de Mensajes \(messageList.count)")
		return messageList.count
	}
	
	func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
		print("el contenido a mostrar \(messageList[indexPath.section])")
		return messageList[indexPath.section]
	}
	
	/*func avatar(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> Avatar {
		var image = UIImage()
		if let correspondentAvatar = conversation.recipient?.image {
			let avatar = UIImageView()
			avatar.kf.setImage(with: correspondentAvatar,
			                   placeholder: nil,
			                   options: [.transition(.fade(1))],
			                   progressBlock: nil,
			                   completionHandler: nil);
			image = avatar.image!
		}
		return Avatar(image: image )
		//SampleData().getAvatarFor(sender: message.sender)
	}*/
	
	func cellTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
		let name = message.sender.displayName
		return NSAttributedString(string: name, attributes: [NSFontAttributeName: UIFont.preferredFont(forTextStyle: .caption1)])
	}
	
	func cellBottomLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
		let formatter = DateFormatter()
		formatter.dateStyle = .medium
		let dateString = formatter.string(from: message.sentDate)
		return NSAttributedString(string: message.sentDate.localizedString/*dateString*/, attributes: [NSFontAttributeName: UIFont.preferredFont(forTextStyle: .caption2)])
	}
	
}

// MARK: - MessagesDisplayDelegate

extension ConversationViewController: MessagesDisplayDelegate {
	
	func textColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
		return isFromCurrentSender(message: message) ? .white : .darkText
	}
	
	func messageStyle(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageStyle {
		let corner: MessageStyle.TailCorner = isFromCurrentSender(message: message) ? .bottomRight : .bottomLeft
		return .bubbleTail(corner, .curved)
	}
	
	func messageFooterView(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageFooterView? {
		return messagesCollectionView.dequeueMessageFooterView(for: indexPath)
	}
	
}

// MARK: - MessagesLayoutDelegate

extension ConversationViewController: MessagesLayoutDelegate {
	
	func avatarAlignment(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> AvatarAlignment {
		return .messageBottom
	}
	
	func footerViewSize(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGSize {
		
		return CGSize(width: messagesCollectionView.bounds.width, height: 10)
	}
	
}

// MARK: - LocationMessageLayoutDelegate

extension ConversationViewController: LocationMessageLayoutDelegate {
	
	func heightForLocation(message: MessageType, at indexPath: IndexPath, with maxWidth: CGFloat, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
		return 200
	}
	
}

// MARK: - MediaMessageLayoutDelegate

extension ConversationViewController: MediaMessageLayoutDelegate {}

// MARK: - MessageCellDelegate

extension ConversationViewController: MessageCellDelegate {
	
	func didTapAvatar<T: UIView>(in cell: MessageCollectionViewCell<T>) {
		print("Avatar tapped")
	}
	
	func didTapMessage<T: UIView>(in cell: MessageCollectionViewCell<T>) {
		print("Message tapped")
	}
	
	func didTapTopLabel<T: UIView>(in cell: MessageCollectionViewCell<T>) {
		print("Top label tapped")
	}
	
	func didTapBottomLabel<T: UIView>(in cell: MessageCollectionViewCell<T>) {
		print("Bottom label tapped")
	}
	
}

// MARK: - MessageLabelDelegate

extension ConversationViewController: MessageLabelDelegate {
	
	func didSelectAddress(_ addressComponents: [String : String]) {
		print("Address Selected: \(addressComponents)")
	}
	
	func didSelectDate(_ date: Date) {
		print("Date Selected: \(date)")
	}
	
	func didSelectPhoneNumber(_ phoneNumber: String) {
		print("Phone Number Selected: \(phoneNumber)")
	}
	
	func didSelectURL(_ url: URL) {
		print("URL Selected: \(url)")
	}
	
}

// MARK: - MessageInputBarDelegate

extension ConversationViewController: MessageInputBarDelegate {
	
	func messageInputBar(_ inputBar: MessageInputBar, didPressSendButtonWith text: String) {
		//let json = JSON.in
		//json["messageId"] = String(Int(self.messageList.last?.messageId) + 1 )
		
		let array: [String: Any] = ["id" : (self.lastid! += 1) , "user_id": App.instance.userModel.id, "content": text ,"updated_at" : dateUtil.instance.dateToString()]
		print("el valor de lastid \(self.lastid)")
		let json = JSON(array)
		//messageList.append(MessageModel(text: text, sender: currentSender(), messageId: UUID().uuidString))
		messageList.append(MessageModel(fromJSON: json))
		inputBar.inputTextView.text = String()
		conversation.send(msg: text.encodeEmoji)
		messagesCollectionView.reloadData()
	}
	
}

