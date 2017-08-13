//
//  listBreeds.swift
//  AnimalsMeet
//
//  Created by Sacha IFRAH on 24/10/2016.
//  Copyright © 2016 AnimalsMeet. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON
import Sensitive

class BreedSelectorTableViewController: UITableViewController, UISearchBarDelegate, UISearchResultsUpdating {
   
   let searchController = UISearchController(searchResultsController: nil)
   var filtered: [BreedModel]!
   var selection: [Int]!
   var onCompletion: (([Int]) -> ())!
   var max: Int?
   
   var firstTimeLoading = true
   
   class func newInstance(selection: [Int], max: Int? = nil, onCompletion: @escaping (([Int]) -> Void)) -> BreedSelectorTableViewController {
      let vc = BreedSelectorTableViewController()
      vc.selection = selection
      vc.max = max
      vc.onCompletion = onCompletion
      return vc
   }
   
   override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      return filtered.count
   }
   
   func selectRow(cell: UITableViewCell?, index: IndexPath, on: Bool) {
      let breed = self.filtered[index.row]
      
      if on {
         if selection.index(where: { $0 == breed.id }) == nil {
            selection.append(breed.id)
         }
         
         tableView.selectRow(at: index, animated: true, scrollPosition: .none)
         cell?.accessoryType = .checkmark
         
         if let max = self.max {
            if max == 1 && selection.count > 1 {
               if let prevIndex = self.filtered.index(where: { $0.id == selection[0] }) {
                  let indexPath = IndexPath(row: prevIndex, section: 0)
                  selectRow(cell: tableView.cellForRow(at: indexPath), index: indexPath, on: false)
               }
               else {
                  selection.removeFirst()
               }
            }
         }
      } else {
         if let idx = selection.index(where: { $0 == breed.id }) {
            selection.remove(at: idx)
         }
         
         tableView.deselectRow(at: index, animated: true)
         cell?.accessoryType = .none
      }
   }
   
   override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
      
      let cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
      
      let breed = filtered[indexPath.row]
      cell.textLabel?.text = breed.nameFr
      cell.textLabel?.textColor = UIColor(hexString: "#6C6F7B")
      cell.selectionStyle = .none
      
      if getSelectionIndex(fromBreedId: breed.id) != nil {
//         tableView.selectRow(at: indexPath, animated: true, scrollPosition: .middle)
//         cell.accessoryType = .checkmark
         self.selectRow(cell: cell, index: indexPath, on: true)
      } else {
//         tableView.deselectRow(at: indexPath, animated: true)
//         cell.accessoryType = .none
         self.selectRow(cell: cell, index: indexPath, on: false)
      }
      return cell
   }
   
   
   func getSelectionIndex(fromBreedId id: Int) -> Int? {
      return selection.index(of: id)
   }
   
   override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
      
      let cell = tableView.cellForRow(at: indexPath)
      let breed = filtered[indexPath.row]
      
      if let _ = getSelectionIndex(fromBreedId: breed.id) {
         self.selectRow(cell: cell, index: indexPath, on: false)
//         selection.remove(at: idx)
//         tableView.deselectRow(at: indexPath, animated: true)
//         cell?.accessoryType = .none
      } else {
            self.selectRow(cell: cell, index: indexPath, on: true)
//         selection.append(breed.id)
//         cell?.accessoryType = .checkmark
//         tableView.selectRow(at: indexPath, animated: true, scrollPosition: .none)
//         self.searchController.isActive = false
         self.navigationController?.popViewController(animated: true)
      }
   }
   
   func updateSearchResults(for searchController: UISearchController) {
      
      let searchText: String! = searchController.searchBar.text?.lowercased()
      if searchText.isEmpty {
         filtered = App.instance.breeds
         tableView.reloadData()
         return
      }
      
      filtered = App.instance.breeds.filter({ breed in
         let text: String = searchText.lowercased()
         return breed.nameFr.lowercased().range(of: text) != nil
      })
      if filtered.count != App.instance.breeds.count {
         tableView.reloadData()
      }
   }
   
   override func viewDidLoad() {
      super.viewDidLoad()
      
      filtered = App.instance.breeds
      searchController.searchResultsUpdater = self
      searchController.dimsBackgroundDuringPresentation = false
      searchController.searchBar.barTintColor = UIColor(hexString: "#aaaaaa")
      searchController.searchBar.tintColor = UIColor.white
      definesPresentationContext = true
      tableView.tableHeaderView = searchController.searchBar
      
      self.view.onSwipe(to: .right) { (swipeGestureRecognizer) -> Void in
         self.navigationController?.popViewController(animated: true)
      }
   }
   
   override func viewWillAppear(_ animated: Bool) {
      super.viewWillAppear(animated)
   
      if let index = self.selection.first, self.firstTimeLoading {
         let indexPath = IndexPath(row: index, section: 0)
         self.tableView.selectRow(at: indexPath, animated: true, scrollPosition: .middle)
      }
      
      self.firstTimeLoading = false
   }
   
   override func viewWillDisappear(_ animated: Bool) {
      super.viewWillDisappear(animated)
      onCompletion?(selection)
      onCompletion = nil
   }
}
