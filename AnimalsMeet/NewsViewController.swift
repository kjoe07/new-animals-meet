//
//  news.swift
//  AnimalsMeet
//
//  Created by Sacha IFRAH on 04/12/2016.
//  Copyright © 2016 AnimalsMeet. All rights reserved.
//

import UIKit
import Floaty

class NewsViewController: UIViewController {
    
    lazy var feedVC = FeedViewController(style: .plain)
    lazy var collectionVC = MosaicViewController(collectionViewLayout: UICollectionViewFlowLayout())
    let button = UIButton()
    var isTVC = true
    var backView: UIView!
    var frontView: UIView?
    var endpoint: String!
    
    func setVC(oldView: UIView?, newView: UIView) {
        
        if let v = oldView {
            v.removeFromSuperview()
        }
        
        view.addSubview(newView)
        newView.frame = view.frame
    }
    
    override func viewDidLoad() {
        feedVC.endpoint = endpoint
        collectionVC.endpoint = endpoint
        super.viewDidLoad()
        self.addChildViewController(feedVC)
        self.addChildViewController(collectionVC)
        backView = feedVC.view
        frontView = collectionVC.view
        swapControllers()

        let padding: CGFloat = 16
        button.imageEdgeInsets = UIEdgeInsets(top: padding, left: padding, bottom: padding, right: padding)
        button.clipsToBounds = true
        button.backgroundColor = #colorLiteral(red: 0, green: 0.620670259, blue: 0.8846479654, alpha: 1)
        button.layer.cornerRadius = 30
        button.addTarget(self, action: #selector(swapControllers), for: .touchUpInside)
        setButtonImage(isTVC)
        self.view.addSubview(button)
        button.snp.makeConstraints { make in
            make.right.equalToSuperview().inset(20)
            make.bottom.equalToSuperview().inset(40)
            make.width.equalTo(60)
            make.height.equalTo(60)
        }
    }
    
    func swapControllers() {
        
        setVC(oldView: frontView, newView: backView)
        self.view.bringSubview(toFront: button) 
        let fv = frontView
        frontView = backView
        backView = fv
        isTVC = !isTVC
        setButtonImage(isTVC)
    }
    
    func setButtonImage(_ tvc: Bool) {
        button.setImage(isTVC ? #imageLiteral(resourceName: "list") : #imageLiteral(resourceName: "grid"), for: .normal)
    }
}
