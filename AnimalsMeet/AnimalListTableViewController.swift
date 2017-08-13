//
//  listanimals.swift
//  AnimalsMeet
//
//  Created by Sacha IFRAH on 08/11/2016.
//  Copyright © 2016 AnimalsMeet. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON
import Sensitive
import PromiseKit

class AnimalListTableViewController: EasyTableViewController<AnimalModel, AnimalListTableViewCell> {
   
   var user: UserModel!
   var createAnimal: (() -> ())!
   var promiseLoadAnimals: Promise<[AnimalModel]>!
   
   override func viewDidLoad() {
      super.viewDidLoad()
      loadingEnabled = true
      tableView.rowHeight = 80
      tableView.allowsSelection = true
   }
   
   override func viewWillAppear(_ animated: Bool) {
      super.viewWillAppear(animated)
      
      if user.isMe {
         self.title = "Mes animaux"
         let header = ViewUseful.instanceFromNib("createAnimal") as! CreateAnimalView
         header.callback = createAnimal
         let frame = CGRect(x: header.frame.minX, y: header.frame.minY, width: header.frame.width, height: 80)
         header.frame = frame
         tableView.tableHeaderView = header
         
         tableView.tableHeaderView!.snp.makeConstraints { make in
            make.height.equalTo(80)
            make.width.equalTo(self.tableView.width)
         }
      }
      else {
         self.title = "Animaux"
      }
   }
   
   override func onPopulateCell(item: AnimalModel, cell: AnimalListTableViewCell) {
      
      cell.configure(picUrl: item.profilePicUrl, name: item.name)
      cell.settings.onTap { _ in
         self.navigationController?.pushViewController(AnimalConfigurationViewController.newInstance(animal: item), animated: true)
      }
      cell.setEditable(item.isMine())
   }
   
   override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
      
      App.instance.userData.selectedAnimal = indexPath.row
      
      let n: Int = navigationController!.viewControllers.count
      let animalVC = navigationController!.viewControllers[n - 2] as! AnimalVC
      animalVC.animal = user.animals![indexPath.row]
      animalVC.reloadAnimal()
   }
   
   override func fetchItems(from: Int, count: Int) -> Promise<[AnimalModel]> {
      
      if theData != nil {
         return Promise(value: [])
      }
      return promiseLoadAnimals ?? Promise { fulfill, reject in }
   }
   
   override func viewDidDisappear(_ animated: Bool) {
      super.viewDidDisappear(animated)
      
      // navigationController?.isNavigationBarHidden = true FIXME
   }
}
