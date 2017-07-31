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

class ChatTableViewController: EasyTableViewController<ConversationModel, ConversationCell>, UISearchBarDelegate {

    var searchController : UISearchController!
    let searchBar = UISearchBar()

    
    @IBAction func newChat(_ sender: Any) {
        // TODO implement dis
    }
    
    override func fetchItems(from: Int, count: Int) -> Promise<[ConversationModel]> {
        
        func matching(_ person: ConversationModel) -> Bool {
            return fuzzySearch(originalString: person.recipient.nickname ?? person.recipient.name!, stringToSearch: searchBar.text!)
        }
        
        return Api.instance.get("/messaging/getCorrespondents/\(from)")
            .then { json -> [ConversationModel] in
                
                let result = JSON(parseJSON: json["correspondents"].stringValue)
                let conversations = result.arrayValue.map {
                    ConversationModel(json: $0)
                    }
                if (self.searchBar.text?.isEmpty)! {
                    return conversations
                } else {
                    return conversations.filter { matching($0) }
                }
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        _ = shouldRefresh()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let ViewForDoneButtonOnKeyboard = UIToolbar()
        ViewForDoneButtonOnKeyboard.sizeToFit()
        let btnDoneOnKeyboard = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(self.doneBtnFromKeyboardClicked))
        ViewForDoneButtonOnKeyboard.items = [btnDoneOnKeyboard]
        searchBar.inputAccessoryView = ViewForDoneButtonOnKeyboard
        
        searchBar.delegate = self
        self.navigationItem.titleView = searchBar
        loadingEnabled = true
        pullToRefreshEnabled = true
        tableView.estimatedRowHeight = 120
        tableView.rowHeight = UITableViewAutomaticDimension
    }
    
    func doneBtnFromKeyboardClicked() {
       self.searchBar.resignFirstResponder()
    }
    
    override func onPopulateCell(item: ConversationModel, cell: ConversationCell) {
        cell.profilePic.kf.setImage(with: item.recipient.image)
        cell.name.text = item.recipient.nickname
        cell.lastMsg.text = item.messages?[0]
        cell.lastMsgTime.text = try! item.date.colloquialSinceNow().colloquial
    
        cell.onTap { _ in
            let vc = ConversationViewController()
            vc.conversation = item
            vc.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}
