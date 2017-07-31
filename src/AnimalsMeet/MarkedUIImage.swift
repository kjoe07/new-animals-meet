//
//  MarkedUIImage.swift
//  AnimalsMeet
//
//  Created by Adrien morel on 1/1/17.
//  Copyright © 2017 AnimalsMeet. All rights reserved.
//

import UIKit

extension UIImage {
    
    static let logoImage = UIImage(named: "logo-meet")!
    static let heatImage = UIImage(named: "fire")!
    
    func image(byDrawingImage image: UIImage, inRect rect: CGRect) -> UIImage? {
        UIGraphicsBeginImageContext(size)
        draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        image.draw(in: rect)
        let result = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return result
    }
}
extension UIImageView {
    
    func mark(image src: UIImage, inImage dest: UIImage, andFrame frame: CGRect, _ done: (() -> ())? = nil) {
        DispatchQueue.main.async {
            self.image = dest.image(byDrawingImage: src, inRect: frame)
            done?()
        }
    }
    
    func markWithHeat() {
        let imgSize = self.image!.size
        let logoSize = imgSize.width / 4
        let scaleFactor = UIImage.heatImage.size.height / UIImage.heatImage.size.width
        let logoWidth = logoSize
        let logoHeight = logoSize * scaleFactor
        let fframe = CGRect(x: 24,
                            y: imgSize.height - logoHeight,
                            width: logoWidth,
                            height: logoHeight)
        mark(image: UIImage.heatImage, inImage: self.image!, andFrame: fframe)
    }
    
    func markUIWithHeat(_ size: CGSize? = nil) -> UIImageView {
        
        let sz = size ?? self.frame.size
        let logoSize = sz.height / 4
        let scaleFactor = UIImage.heatImage.size.height / UIImage.heatImage.size.width
        let logoWidth = logoSize
        let logoHeight = logoSize * scaleFactor
        let fframe = CGRect(x: 4,
                            y: sz.height - logoHeight,
                            width: logoWidth,
                            height: logoHeight)
        
        let imageView = UIImageView(image: UIImage.heatImage)
        imageView.frame = fframe
        self.addSubview(imageView)
        return imageView
    }
    
    func markWithLogo(_ url: URL, _ done: (() -> ())?) {
        
        DispatchQueue.global().async {
            if let imgData = try? Data(contentsOf: url) {
                let img = UIImage(data: imgData)!
                
                let logoSize = img.size.width / 8
                let scaleFactor = UIImage.logoImage.size.height / UIImage.logoImage.size.width
                let logoWidth = logoSize
                let logoHeight = logoSize * scaleFactor
                
                let watermarkerFrame =
                    CGRect(x: img.size.width - logoWidth - 24,
                           y: img.size.height - logoHeight - 24,
                           width: logoWidth,
                           height: logoHeight)
                
                self.mark(image: UIImage.logoImage, inImage: img, andFrame: watermarkerFrame, done)
            }
        }
    }
    
}
