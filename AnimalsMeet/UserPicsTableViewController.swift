//
//  listPictures.swift
//  AnimalsMeet
//
//  Created by Sacha IFRAH on 04/12/2016.
//  Copyright © 2016 AnimalsMeet. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON
import PromiseKit
import ARSLineProgress
import Fusuma
import SnapKit

class UserPicsTableViewController: EasyTableViewController<MediaModel, MediaCell> {
   
   var user: UserModel!
   var animal: AnimalModel!
   var newMedia: MediaModel!
   
   override func viewDidLoad() {
      super.viewDidLoad()
      pullToRefreshEnabled = true
      loadingEnabled = true
      pageTabBarItem.title = "Photos"
      pageTabBarItem.titleColor = .gray
   }
   
   var realCount = 0
   
   override func fetchItems(from: Int, count: Int) -> Promise<[MediaModel]> {
      if theData == nil {
         realCount = 0
      }
      
      return unready.promiseReady.then {
         Api.instance.get("/user/\(self.user.id!)/images/\(self.realCount)").then { JSON -> [MediaModel] in
            // PATCH: count the number of items without being filtered 
            self.realCount += JSON["images"].arrayValue.count
            
            return JSON["images"].arrayValue.map {
               MediaModel(fromJSON: $0)
               }.filter {
                  $0.animal.id != 0
            }
         }
      }
   }
   
   override func onPopulateCell(item: MediaModel, cell: MediaCell) {
      
      cell.profilePic.rounded()
      cell.setMedia(item)
      
      cell.mediaView.onTap {_ in
         presentFullScreen(imageURL: item.url, onVC: self, media: item)
      }
      
      cell.goToProfile = {
         self.navigationController?.pushViewController(AnimalVC.newInstance(item.animal), animated: true)
      }
      cell.goToComments = {
         self.navigationController?.hidesBottomBarWhenPushed = true
         self.navigationController?.pushViewController(CommentViewController.newInstance(item), animated: true)
      }
   }
   
   override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
      
      let height = CGFloat(theData[indexPath.row].width)
      let width = CGFloat(theData[indexPath.row].height)
      let scaleFactor = UIScreen.main.scale
      let screenWidth = CGFloat(UIScreen.main.bounds.width)
      
      return (height / (width / (screenWidth * scaleFactor))) / scaleFactor + 100
   }
   
   
   
}
