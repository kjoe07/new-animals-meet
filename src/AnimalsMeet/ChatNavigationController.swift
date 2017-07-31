//
//  ChatNavigationController.swift
//  AnimalsMeet
//
//  Created by Adrien morel on 20/05/2017.
//  Copyright © 2017 AnimalsMeet. All rights reserved.
//

import UIKit

class ChatNavigationController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()
        let chatVC = ChatTableViewController(style: .plain)
        setViewControllers([chatVC], animated: false)
    }
}
