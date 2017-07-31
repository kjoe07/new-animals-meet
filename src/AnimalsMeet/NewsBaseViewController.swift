//
//  NewsBaseViewController.swift
//  AnimalsMeet
//
//  Created by Adrien morel on 07/06/2017.
//  Copyright © 2017 AnimalsMeet. All rights reserved.
//

import UIKit
import Material

class NewsBaseViewController: UINavigationController, PageTabBarControllerDelegate {
    
    var pagerVC: PageTabBarController!
    var feedFriends: NewsViewController!
    var feedPublic: NewsViewController!
    let fontSize: CGFloat = 18

    func setPostButton() {
        
        let image = #imageLiteral(resourceName: "post")
        let v = UIButton(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        v.contentMode = .scaleAspectFit
        v.setImage(image, for: .normal)
        v.addTarget(self, action: #selector(newPost), for: .touchUpInside)
        let barButton = UIBarButtonItem(customView: v)
        
        pagerVC.navigationItem.setRightBarButton(barButton, animated: true)
        pagerVC.title = "Actualités"
    }
    
    func newPost() {
        let PostVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "newPost")
        present(PostVC, animated: true, completion: nil)    
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        feedFriends = NewsViewController()
        feedFriends.endpoint = "/feeds/friends"
        feedPublic = NewsViewController()
        feedPublic.endpoint = "/feeds/public"
        
        feedFriends.pageTabBarItem.title = "Amis"
        feedFriends.pageTabBarItem.titleLabel!.font = UIFont.boldSystemFont(ofSize: fontSize)
        feedPublic.pageTabBarItem.title = "Public"
        pagerVC = PageTabBarController(viewControllers: [feedFriends, feedPublic])
        pagerVC.delegate = self
        pagerVC.pageTabBarAlignment = .top
        pagerVC.pageTabBar.lineAlignment = .bottom
        navigationBar.isOpaque = true
        pagerVC.edgesForExtendedLayout = []
        pushViewController(pagerVC, animated: false)
        view.backgroundColor = .white
        setPostButton()
    }
    
    func pageTabBarController(pageTabBarController: PageTabBarController, didTransitionTo viewController: UIViewController) {
        if viewController == feedPublic {
            feedFriends.pageTabBarItem.titleLabel!.font = UIFont.systemFont(ofSize: fontSize)
            feedPublic.pageTabBarItem.titleLabel!.font = UIFont.boldSystemFont(ofSize: fontSize)
        } else {
            feedPublic.pageTabBarItem.titleLabel!.font = UIFont.systemFont(ofSize: fontSize)
            feedFriends.pageTabBarItem.titleLabel!.font = UIFont.boldSystemFont(ofSize: fontSize)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
}
