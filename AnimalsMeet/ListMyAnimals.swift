//
//  ListMyAnimals.swift
//  AnimalsMeet
//
//  Created by Sacha IFRAH on 05/01/2017.
//  Copyright © 2017 AnimalsMeet. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON

/*
class ListMyAnimals : UITableViewController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return App.instance.userData.animals.count
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        /* TODO: select animal
        let memory = UserDefaults.standard
        let id = items[indexPath.row]["id"].int
        memory.set(id, forKey: "active_animal_id")
        let controller = self.parent as! AnimalVC
        controller.initialize_animal_object()
 */
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LabelCell", for: indexPath) as! ListMyAnimalsCell
        
        let animal = App.instance.userData.animals[indexPath.row]
        
        cell.profil_pic.kf.setImage(with: animal.profilePicUrl,
                             placeholder: nil,
                             options: [.transition(.fade(1))],
                             progressBlock: nil,
                             completionHandler: nil);
        
        cell.profil_pic.layer.cornerRadius = cell.profil_pic.frame.size.width / 2
        cell.profil_pic.clipsToBounds = true

        if animal.id == App.instance.userData.selectedAnimal {
            tableView.selectRow(at: indexPath, animated: true, scrollPosition: .middle)
        }
        cell.name_age.text = "\(animal.name), \(animal.year) ans"
        cell.breed.text = "\(animal.breedName())"
        
        return cell
    }
    
}
 */
