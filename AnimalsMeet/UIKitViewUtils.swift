//
//  UIKitViewUtils.swift
//  AnimalsMeet
//
//  Created by Davy on 08/11/2016.
//  Copyright © 2016 AnimalsMeet. All rights reserved.
//

import Foundation
import UIKit

class UIKitViewUtils {
    static func setCornerRadius(sender: UIView, radius: CGFloat) {
        sender.layer.cornerRadius = radius
        sender.clipsToBounds = true
    }

    static func setBorderWidth(sender: UIView, width: CGFloat, hexString: String) {
        sender.layer.borderWidth = width
        sender.layer.borderColor = UIColor.init(hexString: hexString).cgColor
    }
    
    static func addVC(to vc: UIViewController, inView view: UIView, withIdentifier identifier: String) -> UIViewController {
        let controller = (vc.storyboard?.instantiateViewController(withIdentifier: identifier))!

        vc.addChildViewController(controller)
        view.addSubview((controller.view)!)
        controller.view.frame = view.bounds
        controller.didMove(toParentViewController: vc)
        return controller
    }
    
    static func showLabelInCenter(withText text: String, inView view: UIView) {
        
        let label = UILabel()
        label.text = text
        label.textAlignment = .center
        putViewInCenter(label, inCenterOf: view)
    }
    
    static func putViewInCenter(_ view: UIView, inCenterOf containingView: UIView) {
        
        containingView.addSubview(view)
        view.frame = containingView.frame
        view.center = containingView.center
        view.setNeedsDisplay()
    }

}
