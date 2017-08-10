//
//  ProfileTabViewController.swift
//  AnimalsMeet
//
//  Created by Adrien morel on 06/06/2017.
//  Copyright © 2017 AnimalsMeet. All rights reserved.
//

import UIKit
import Material

class ProfileTabViewController: PageTabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        pageTabBarAlignment = .top
        pageTabBar.lineAlignment = .bottom
    }
}
