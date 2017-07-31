//
//  user_forgot_password.swift
//  AnimalsMeet
//
//  Created by Sacha IFRAH on 17/10/2016.
//  Copyright © 2016 AnimalsMeet. All rights reserved.
//

import Foundation
import UIKit

class user_forgot_password: UIViewController {
    var userData: UserModel!;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.userData = UserModel();
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}
