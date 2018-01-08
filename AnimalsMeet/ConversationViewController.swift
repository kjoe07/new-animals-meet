//
//  ConversationViewController.swift
//  AnimalsMeet
//
//  Created by Yoel Jimenez del Valle on 12/12/2017.
//  Copyright © 2016 AnimalsMeet. All rights reserved.
//

import UIKit
import SwiftyJSON
import Kingfisher
import MessageKit

class ConversationViewController: MessagesViewController{
	var messageList: [MessageModel] = []
	var pageN :Int!
	var recipientId: Int!
	var conversation: ConversationModel!
	var lastid: Int!
	var timer: Timer!
	override func viewDidLoad() {
		super.viewDidLoad()
		
		let showProfile = UIBarButtonItem(title: "Voir le profil", style: .plain, target: self, action: #selector(showRecipientProfile))
		self.navigationItem.rightBarButtonItem = showProfile
	
		self.timer = Timer.scheduledTimer(timeInterval: 2.0, target: self, selector: #selector(self.refreshConv), userInfo: nil, repeats: true);
		
		//self.navigationItem.title = conversation.recipient.name
		//self.automaticallyAdjustsScrollViewInsets = false
		automaticallyAdjustsScrollViewInsets = false
		self.refreshConv()
		messagesCollectionView.messagesDataSource = self
		messagesCollectionView.messagesLayoutDelegate = self
		messagesCollectionView.messagesDisplayDelegate = self
		messagesCollectionView.messageCellDelegate = self
		messageInputBar.delegate = self
		self.messageInputBar.inputTextView.placeholder = "Message..."
		self.messageInputBar.sendButton.title = "Envoyer"
		self.messageInputBar.sendButton.titleLabel?.adjustsFontSizeToFitWidth = true
	}
	override func viewWillAppear(_ animated: Bool) {
		(self.tabBarController as? AnimalTabBarController)?.centerButton.isHidden = true
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		(self.tabBarController as? AnimalTabBarController)?.centerButton.isHidden = false
		self.timer.invalidate()
	}
	func showRecipientProfile() {
		let recipientProfileVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "AnimalVC") as! AnimalVC
		//recipientProfileVC.shouldHideNavigationBar = false
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
		if self.pageN == nil {
			self.pageN = 1
		}
		Api.instance.get("/messaging/\(conversation.recipient.id!)/\(self.pageN!)"/**/)
			.then { json -> Void in

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
						//let lastRow: Int = self.messagesCollectionView.numberOfItems(inSection: 0) - 1//numberOfRows(inSection: 0) - 1
						//let indexPath = IndexPath(row: lastRow, section: 0);
						self.messagesCollectionView.scrollToBottom()//scrollToRow(at: indexPath, at: .top, animated: false)
					}
				}
			}.catch { err in
		}
	}
	
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
	
	func avatar(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> Avatar {
		var image = UIImage(named: "anonymous")
		//let avatar = UIImageView()
		if Int(message.sender.id) != App.instance.userModel.id {
		if let correspondentAvatar = conversation.recipient?.image {
			let avatar = UIImageView()
			avatar.kf.setImage(with: correspondentAvatar,
			                   placeholder: nil,
			                   options: [.transition(.fade(1))],
			                   progressBlock: nil,
			                   completionHandler: nil)
			image = avatar.image
		}
		
			return Avatar(image: image)/**/
			
		}else{
				let avatar = UIImageView()
				avatar.kf.setImage(with: App.instance.userModel.image,placeholder: nil,options:[.transition(.fade(1))],progressBlock: nil,completionHandler: nil)
				image = avatar.image
			return Avatar(image: image)
		}
		//let ir = Avatar()
		
		//SampleData().getAvatarFor(sender: message.sender)/**/
		/*if Int(messageList[indexPath.row].sender.id) == App.instance.userModel.id{
			return Avatar.init(image: nil, initals: "Me")
		}else{
			return Avatar.init(image: nil, initals: "Rp")
		}*/
	}
	
	func cellTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
		let name = message.sender.displayName
		return NSAttributedString(string: name, attributes: [NSFontAttributeName: UIFont.preferredFont(forTextStyle: .caption1)])
	}
	
	func cellBottomLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
		let formatter = DateFormatter()
		formatter.dateStyle = .medium
		//let dateString = formatter.string(from: message.sentDate)
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
		if self.lastid == nil{
			self.lastid = 0
		}
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

