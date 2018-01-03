//
//  UserListViewController.swift
//  AnimalsMeet
//
//  Created by Reynaldo Aguilar on 8/27/17.
//  Copyright © 2017 AnimalsMeet. All rights reserved.
//

import UIKit

class UserListViewController: UITableViewController {
   var users: [UserModel]
   
   init(users: [UserModel]) {
      self.users = users
      super.init(nibName: nil, bundle: nil)
   }
   
   required init?(coder aDecoder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
   }
   
   override func viewDidLoad() {
      super.viewDidLoad()
      
      let nib = UINib(nibName: UserTableViewCell.identifier, bundle: .main)
      tableView.register(nib, forCellReuseIdentifier: UserTableViewCell.identifier)
      
      tableView.rowHeight = 70
      // Uncomment the following line to preserve selection between presentations
      // self.clearsSelectionOnViewWillAppear = false
      
      // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
      // self.navigationItem.rightBarButtonItem = self.editButtonItem()
   }
   
   // MARK: - Table view data source
   
   override func numberOfSections(in tableView: UITableView) -> Int {
      // #warning Incomplete implementation, return the number of sections
      return 1
   }
   
   override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      // #warning Incomplete implementation, return the number of rows
      return users.count
   }
   
   override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
      let cell = tableView.dequeueReusableCell(
         withIdentifier: UserTableViewCell.identifier,
         for: indexPath
      ) as! UserTableViewCell
      
      let item = self.users[indexPath.row]
      cell.item = item
      return cell
   }
 
   override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
      let user = users[indexPath.row]
      let profileVC = AnimalVC.newInstance(user)
	//profileVC.shouldHideNavigationBar = false
      
      _ = Api.instance.get("/user/\(user.id!)/animals")
         .then { json -> [AnimalModel] in
            json["animals"].arrayValue.map {AnimalModel(fromJSON: $0) }
         }
         .then { animals -> Void in
            profileVC.animal = animals.first
            self.navigationController?.pushViewController(profileVC, animated: true)
      }
      
//      self.navigationController?.pushViewController(profileVC, animated: true)
   }
   
   /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
    // Return false if you do not want the specified item to be editable.
    return true
    }
    */
   
   /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
    if editingStyle == .delete {
    // Delete the row from the data source
    tableView.deleteRows(at: [indexPath], with: .fade)
    } else if editingStyle == .insert {
    // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }
    }
    */
   
   /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
    
    }
    */
   
   /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
    // Return false if you do not want the item to be re-orderable.
    return true
    }
    */
   
   /*
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.
    }
    */
   
}
