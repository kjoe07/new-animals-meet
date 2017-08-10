//
//  Utils.swift
//  AnimalsMeet
//
//  Created by gwendal lasson on 09/06/2017.
//  Copyright © 2017 AnimalsMeet. All rights reserved.
//

import UIKit
import Lightbox

func presentFullScreen(image: UIImage, onVC VC: UIViewController) {
    let controller = LightboxController(images: [LightboxImage(image: image)])
    VC.present(controller, animated: true, completion: nil)
}

func presentFullScreen(imageURL: URL, onVC VC: UIViewController) {
    let controller = LightboxController(images: [LightboxImage(imageURL: imageURL)])
    VC.present(controller, animated: true, completion: nil)
}
