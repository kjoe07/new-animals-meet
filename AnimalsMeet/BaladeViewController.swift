//
//  BaladeViewController.swift
//  AnimalsMeet
//
//  Created by gwendal lasson on 08/06/2017.
//  Copyright © 2017 AnimalsMeet. All rights reserved.
//

import UIKit

class BaladeViewController: UIViewController {
   
   @IBOutlet weak var distanceSlider: UISlider!
   @IBOutlet weak var distance: UILabel!
   @IBOutlet weak var followedFriends: UISwitch!
   @IBOutlet weak var baladeDescription: UITextView!
   var animalId: Int!
   
   override func viewDidLoad() {
      super.viewDidLoad()
      self.sliderChanged(distanceSlider)
   }
   
   @IBAction func sliderChanged(_ sender: UISlider) {
      let value = String(format: "%.2f", sender.value)
      distance.text = "\(value) Km"
   }
   
   @IBAction func send(_ sender: Any) {
      _ = Api.instance.post("/hike", withParams: ["hike[content]" : baladeDescription.text!, "hike[sendFriends]" :followedFriends.isOn, "hike[animal_id]" :  App.instance.userData.selectedAnimal, "hike[distanceInKm]" : Int(distanceSlider.value)])
         .then { _ in alert.showAlertSuccess(title: "Succès", subTitle: "La balade a été créée") }
         .catch { _ in alert.showAlertError(title: "Erreur", subTitle: "Une erreur est survenue en créant la balade") }
   }
}
