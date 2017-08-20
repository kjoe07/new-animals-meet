//
//  ChatTableViewController.swift
//  AnimalsMeet
//
//  Created by Adrien Morel on 06/12/2016.
//  Copyright © 2016 AnimalsMeet. All rights reserved.
//

import UIKit
import NMessenger
import SwiftyJSON
import PromiseKit
import AFDateHelper
import SwiftDate

class ChatTableViewController: EasyTableViewController<ConversationModel, ConversationCell> {
   
   @IBAction func newChat(_ sender: Any) {
      // TODO implement dis
   }
   
   override func fetchItems(from: Int, count: Int) -> Promise<[ConversationModel]> {
      return Api.instance.get("/messaging/getCorrespondents/\(from + 1)")
         .then { json -> [ConversationModel] in
            
            let result = JSON(parseJSON: json["correspondents"].stringValue)
            let conversations = result.arrayValue.map {
               ConversationModel(json: $0)
            }
            
            return conversations
      }
   }
   
   override func viewDidLoad() {
      super.viewDidLoad()
      
      let ViewForDoneButtonOnKeyboard = UIToolbar()
      ViewForDoneButtonOnKeyboard.sizeToFit()
      let btnDoneOnKeyboard = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(self.doneBtnFromKeyboardClicked))
      ViewForDoneButtonOnKeyboard.items = [btnDoneOnKeyboard]
      loadingEnabled = true
      pullToRefreshEnabled = true
      tableView.estimatedRowHeight = 120
      tableView.rowHeight = UITableViewAutomaticDimension
   }
   
   func doneBtnFromKeyboardClicked() {
   }
   
   override func onPopulateCell(item: ConversationModel, cell: ConversationCell) {
      cell.profilePic.kf.setImage(with: item.recipient.image)
      cell.name.text = item.recipient.nickname
      cell.lastMsg.text = item.messages?[0]
      let region = Region(tz: TimeZoneName.europeParis, cal: CalendarName.current, loc: LocaleName.french)
      cell.lastMsgTime.text = try! item.date.colloquialSinceNow(in: region).colloquial
      
      cell.onTap { _ in
         let vc = ConversationViewController()
         vc.conversation = item
         vc.hidesBottomBarWhenPushed = true
         self.navigationController?.pushViewController(vc, animated: true)
      }
   }
}
