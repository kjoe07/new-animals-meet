//
//  AnimalTabBarController.swift
//  AnimalsMeet
//
//  Created by Davy on 22/10/2016.
//  Copyright © 2016 AnimalsMeet. All rights reserved.
//

import UIKit
import Foundation
import SwiftyJSON

class AnimalTabBarController: UITabBarController {
    
    var centerButton: UIButton!
    
    func addCenterButton() -> UIButton {
        let tabBarHeight = tabBar.layer.bounds.height * 1.4
        
        let mainButton: UIButton = UIButton(type: .custom)
        let win: UIWindow = ((UIApplication.shared.delegate?.window)!)!
        
        mainButton.frame = CGRect(origin: CGPoint(x: 0.0, y: win.frame.size.height),
                              size: CGSize(width: tabBarHeight, height: tabBarHeight))
        mainButton.center = CGPoint(x: win.center.x, y: win.frame.size.height - tabBar.layer.bounds.height)
        
        mainButton.setBackgroundImage(UIImage(named: "logo_button"), for: .normal)

        mainButton.addTarget(self, action: #selector(onButtonPressed), for: .touchUpInside)
        mainButton.accessibilityIdentifier = "mainButton"

        mainButton.layer.zPosition = 10

        self.view.addSubview(mainButton)
        return mainButton
    }

    func onButtonPressed(button: UIButton) {
        self.selectedIndex = 2
    }
    
    func resizeImage(image: UIImage, newWidth: CGFloat) -> UIImage {
        
        let scale = newWidth / image.size.width
        let newHeight = image.size.height * scale
        UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newWidth))
        image.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        return newImage
    }
    
    func makeItRounded(size: CGSize, image: UIImage, color: String) -> UIImage {
        
        let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        UIGraphicsBeginImageContextWithOptions(size, false, 0);
        let ctx = UIGraphicsGetCurrentContext()!
        UIColor.clear.set()
        ctx.fill(rect)
        ctx.setStrokeColor(UIColor.init(hexString: color).cgColor)
        ctx.setLineWidth(1.0)
        
        UIBezierPath(roundedRect: rect, cornerRadius: size.width / 2).addClip()
        
        image.draw(in: rect)
        let finalImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return finalImage!
    }

    /*
    func useAnimalProfilePic() {
        
        let json = JSON([:])
        let url = URL(string: ApiConnector().API_URL+"media/"+json["animal"]["profil_media"].stringValue)!
        
        
        
        let tabbaritem = self.viewControllers?[self.viewControllers!.count - 1].tabBarItem!
        NotificationTableViewController.rightTab = tabbaritem
        
        DispatchQueue.global().async() {
            var image_data = Data()
            
            if (json != JSON.null) {
                image_data = try! Data(contentsOf: url)
            }
            
            DispatchQueue.main.async() {
                 if (json != JSON.null) {
                    var image = UIImage(data: image_data)
                    
                    image = self.resizeImage(image: image!, newWidth: 25)
                    image = self.makeItRounded(size: (image?.size)!, image: image!, color:"#E42772")
                    image = image?.withRenderingMode(.alwaysOriginal)
                    tabbaritem?.image = image
                    tabbaritem?.selectedImage = image
                }
                
                /*if (json["animal"]["sex"].string == "f") {
                    UIKitViewUtils.setBorderWidth(sender: test, width: 1.0, hexString: "#E42772")
                } else {
                    UIKitViewUtils.setBorderWidth(sender: test, width: 1.0, hexString: "#2978AC")
                }*/
            }
        }
    }
 */
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.selectedIndex = 2
        centerButton = addCenterButton()
        // NotificationTableViewController.loadNotifications() TODO
    }
    
}

extension UIImage {
    func imageByAddingBorder(borderWidth width: CGFloat, borderColor color: UIColor) -> UIImage {
        UIGraphicsBeginImageContext(self.size)
        let imageRect = CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height)
        self.draw(in: imageRect)
        
        let ctx = UIGraphicsGetCurrentContext()
        let borderRect = imageRect.insetBy(dx: width / 2, dy: width / 2)
        
        ctx!.setStrokeColor(color.cgColor)
        ctx!.setLineWidth(width)
        ctx!.stroke(borderRect)
        
        let borderedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return borderedImage!
    }
}
