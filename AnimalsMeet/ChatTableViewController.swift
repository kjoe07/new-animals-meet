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

class ChatTableViewController: EasyTableViewController<ConversationModel, ConversationCell>,UISearchResultsUpdating,UISearchBarDelegate,UISearchControllerDelegate  {
   
    @IBAction func newChat(_ sender: Any) {
      // TODO implement dis
    }
    let searchController = UISearchController(searchResultsController: nil)
    override func fetchItems(from: Int, count: Int) -> Promise<[ConversationModel]> {
      return Api.instance.get("/messaging/getCorrespondents/\(from + 1)")
         .then { json -> [ConversationModel] in
            let result =  json["correspondents"]//JSON(parseJSON: json) //.stringValue
            let conversations = result.arrayValue.map {
               ConversationModel(json: $0)
                }.filter { m -> Bool in
                    debugPrint(m)
                    let y =  self.searchController.searchBar.text != nil && self.searchController.searchBar.text != "" ? (m.recipient.nickname?.lowercased().contains(self.searchController.searchBar.text!.lowercased()) ?? false) : true
                    print("y value \(y)")
                    return y
            }
            print(conversations.count)
            return conversations
      }
    }
   
    override func viewDidLoad() {
      super.viewDidLoad()
      //searchController.searchBar.sizeToFit()
      //self.navigationItem.titleView = searchController.searchBar
      let ViewForDoneButtonOnKeyboard = UIToolbar()
      ViewForDoneButtonOnKeyboard.sizeToFit()
      let btnDoneOnKeyboard = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(self.doneBtnFromKeyboardClicked))
      ViewForDoneButtonOnKeyboard.items = [btnDoneOnKeyboard]
      loadingEnabled = true
      pullToRefreshEnabled = true
      tableView.estimatedRowHeight = 120
      tableView.rowHeight = UITableViewAutomaticDimension
      /*searchController.searchResultsUpdater = self
      definesPresentationContext = true
      searchController.dimsBackgroundDuringPresentation = false
      self.searchController.hidesNavigationBarDuringPresentation = false
      //self.searchController.searchBar.showsCancelButton = true
        let image = #imageLiteral(resourceName: "post")
        let v = UIButton(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        v.contentMode = .scaleAspectFit
        v.setImage(image, for: .normal)
        v.addTarget(self, action: #selector(activeSearchBar), for: .touchUpInside)
        v.roundify()
        v.backgroundColor = #colorLiteral(red: 0.4651720524, green: 0.7858714461, blue: 0.9568093419, alpha: 1)
        let barButton = UIBarButtonItem(customView: v)
        self.navigationItem.setRightBarButton(barButton, animated: true)
      searchController.searchBar.delegate = self/**/*/
    }
   
    func doneBtnFromKeyboardClicked() {
    }
   
    override func onPopulateCell(item: ConversationModel, cell: ConversationCell) {
        //print("la lectura \(item.)")
      cell.profilePic.kf.setImage(with: item.recipient.image)
      cell.name.text = item.recipient.nickname
		if let message = item.messages{
			cell.lastMsg.text = message[0].decodeEmoji
			//cell.lastMsgTime.text = item.date.localizedString
		}
		if let date = item.date{
			cell.lastMsgTime.text = date.localizedString
		}
      cell.onTap { _ in
        let vc = ConversationViewController()
		 vc.conversation = item
		//vc.recipientId = item.recipient.id
		
        vc.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(vc, animated: true)
      }
    }
    /* func filterContentForSearchText(searchText:String,scope:String = "All"){
        news.instance.filter(search: searchText)
    }*/
    func updateSearchResults(for searchController: UISearchController) {
       /* news.instance.filteredData.removeAll()
        filterContentForSearchText(searchText: searchController.searchBar.text!)
        if news.instance.filteredData.count == 0{
            HUD.flash(.label("No existen Noticias para el criterio de búsqueda seleccionado"), delay: 1.5){ _ in
                print("No existen Noticias nuevas")
            }
        }
        self.mytableView.reloadData()*/
        let _ = self.shouldRefresh()
    }
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.searchController.searchBar.text = nil
        searchController.searchBar.resignFirstResponder()
       let _ = self.shouldRefresh()
    }
    func activeSearchBar(){
        self.searchController.searchBar.becomeFirstResponder()
    }
}
