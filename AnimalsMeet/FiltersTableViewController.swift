//
//  filterSetting.swift
//  AnimalsMeet
//
//  Created by Davy on 02/11/2016.
//  Copyright © 2016 AnimalsMeet. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON
import Sensitive
class FilterSettingTableViewController : UITableViewController {
    
    @IBOutlet var register: UIButton!
    @IBOutlet var race: UIButton!
    
    @IBOutlet var dog: UISwitch!
    @IBOutlet var cat: UISwitch!
    @IBOutlet var male: UISwitch!
    @IBOutlet var female: UISwitch!
    @IBOutlet var heat: UISwitch!
    @IBOutlet var lof: UISwitch!
    
    override func viewWillAppear(_ animated: Bool) {
        
        for item in (tabBarController?.view.subviews)! {
            if item.accessibilityIdentifier == "mainButton" {
                item.isHidden = true
            }
        }
		//self.navigationItem.title
        //navigationItem.title = "Filtrez votre recherche"
		self.title = "Filtrez votre recherche"
        navigationItem.backBarButtonItem?.title = "Filtrez votre recherche"
        
        let radius: CGFloat = register.bounds.height * 0.5
        UIKitViewUtils.setCornerRadius(sender: register, radius: radius)
        UIKitViewUtils.setCornerRadius(sender: race, radius: radius)
    }
    
    @IBAction func selectBreed(_ sender: Any) {
        
        let breedSelectorVC = BreedSelectorTableViewController.newInstance(selection: Search.instance.breeds) { breeds in
            Search.instance.breeds = breeds
        }
        
        navigationController?.pushViewController(breedSelectorVC, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        //navigationItem.title = nil
		self.title = nil
        if (segue.identifier == "execSearch") {
           self.navigationController?.popToRootViewController(animated: true)
            //let vc = segue.destination as! SearchResultsViewController
            //vc.search.filter_range_km = Int(0);
        }
    }
    
    @IBAction func onSaveFilter(_ sender: Any) {
        Search.instance.dog = dog.isOn
        Search.instance.cat = cat.isOn
        Search.instance.female = female.isOn
        Search.instance.male = male.isOn
        Search.instance.heat = heat.isOn
        Search.instance.loof = lof.isOn
        navigationController?.popViewController(animated: true)
    }

    @IBAction func onCheckHeat(_ sender: UISwitch) {
        
        if sender.accessibilityIdentifier == "heat" {
            if sender.isOn == true {
                female.setOn(true, animated: true)
            }
        } else if sender.accessibilityIdentifier == "female" {
            if sender.isOn == false && self.heat.isOn == true {
                male.setOn(false, animated: true)
            }
        } else if sender.accessibilityIdentifier == "male" {
            if sender.isOn == true && self.female.isOn == false {
                heat.setOn(false, animated: true)
            }
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.onSwipe(to: .right) { (swipeGestureRecognizer) -> Void in
            self.navigationController?.popToRootViewController(animated: true)
        }
        
        dog.setOn(Search.instance.dog, animated: false)
        cat.setOn(Search.instance.cat, animated: false)
        female.setOn(Search.instance.female, animated: false)
        male.setOn(Search.instance.male, animated: false)
        heat.setOn(Search.instance.heat, animated: false)
        lof.setOn(Search.instance.loof, animated: false)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if isMovingFromParentViewController {
           onSaveFilter(self)
        }
    }
}
