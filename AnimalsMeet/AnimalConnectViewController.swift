//
//  AnimalConnectViewController.swift
//  AnimalsMeet
//
//  Created by Davy on 21/10/2016.
//  Copyright © 2016 AnimalsMeet. All rights reserved.
//

import UIKit
import Foundation
import SwiftLocation
import SwiftyJSON

class AnimalConnectViewController : UIViewController {
    @IBOutlet var topView: UIView!

    @IBOutlet weak var doBalade: UIButton!
    @IBOutlet var searchButton: UIButton!
    @IBOutlet var filterButton: UIButton!
    @IBOutlet var rangeTxt: UILabel!
    
    @IBAction func clickSearch(_ sender: Any) {
        performSegue(withIdentifier: "doSearch", sender: self)
    }
    
    @IBOutlet var rangeSlider: UISlider!
    
    var searchResult: JSON?
    var currentlyPopping = false

    func popViewOutOfButton() {
        
        let halo = UIView(frame: searchButton.frame)
        halo.layer.backgroundColor = #colorLiteral(red: 0.2010400891, green: 0.5959115624, blue: 0.8570745587, alpha: 1).cgColor
        view.addSubview(halo)
        halo.rounded()
        halo.layer.opacity = 0.3
        halo.isUserInteractionEnabled = false
        searchButton.layer.zPosition = 1
        
        UIView.animate(withDuration: 6, delay: 0, options: [.curveEaseOut], animations: {
            halo.layer.opacity = 0
            halo.transform = CGAffineTransform(scaleX: 2, y: 2)
        }, completion: { _ in
            halo.removeFromSuperview()
        })
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if currentlyPopping {
            return
        }
        
        UIView.animate(withDuration: 1.9, delay: 0, options: [.repeat, .autoreverse, .curveEaseInOut, .allowUserInteraction], animations: {
            self.searchButton.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        }, completion: nil)
        
        currentlyPopping = true
        self.popViewOutOfButton()
        Timer.scheduledTimer(withTimeInterval: 1.5, repeats: true) {_ in
            self.popViewOutOfButton()
        }
    }
    
    @IBAction func balade(_ sender: Any) {
        let baladeVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "baladeVC")
        navigationController?.pushViewController(baladeVC, animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tabBarController?.tabBar.isHidden = false
        
        for item in (tabBarController?.view.subviews)! {
            if item.accessibilityIdentifier == "mainButton" {
                item.isHidden = false
                item.layer.zPosition = 10
            }
        }
        
        let radius: CGFloat = filterButton.bounds.height * 0.5
        UIKitViewUtils.setCornerRadius(sender: filterButton, radius: radius)
        
        self.searchButton.transform = CGAffineTransform.identity
    }
    
    @IBAction func setValue(_ sender: AnyObject) {
        rangeTxt.text = "\(Int(rangeSlider.value)) Km"
        Search.instance.range = Int(rangeSlider.value)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        searchButton.imageView?.contentMode = UIViewContentMode.scaleAspectFit
        
        rangeSlider.setValue(Float(Search.instance.range), animated: false)
        rangeTxt.text = "\(Search.instance.range) Km"
        print(Search.instance.range)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "doSearch" {
            Search.instance.range = Int(rangeSlider.value)
        }
    }
}
