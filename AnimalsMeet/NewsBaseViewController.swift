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
      v.roundify()
      v.backgroundColor = #colorLiteral(red: 0.4651720524, green: 0.7858714461, blue: 0.9568093419, alpha: 1)
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
   override func viewDidAppear(_ animated: Bool){
	 print("ya aperecio")
		self.feedFriends.feedVC.tableView.reloadData()
	
        /*if let postId = feedFriends.postId {
            let i = feedFriends.feedVC.theData.index(where: { data in
                
                data.id == postId
            })
            print("i value: \(i)")
            let indexPath = IndexPath.init(row: i!, section: 0)
            feedFriends.feedVC.tableView.scrollToRow(at: indexPath , at: .top, animated: true)
        }*/
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        if let postID = appDelegate.postID, let data = feedFriends.feedVC.theData {
			print("entro en la condicion")
            self.pagerVC.selectedIndex = 0
			//self.feedFriends.feedVC.tableView.reloadData()
			let i = self.feedFriends.feedVC.theData.index(where: { data in
				//print("el valor de Data.Index: \(data.id)")
				data.id == postID
			})
			print("i value: \(String(describing: i))")
			let indexPath = IndexPath.init(row: i!, section: 0)
			self.feedFriends.feedVC.tableView.scrollToRow(at: indexPath , at: .top, animated: true)
			appDelegate.postID = nil
			print("el valor de post id \(String(describing: appDelegate.postID))")
           // let i = data.index(where: { data in
             //   data.id == postID
            //})
            /*print("i value: \(i)")
            let indexPath = IndexPath.init(row: i!, section: 0)
            feedFriends.feedVC.tableView.scrollToRow(at: indexPath , at: .top, animated: true)
            appDelegate.postID = nil
            print("el valor de post id \(String(describing: appDelegate.postID))")*/
		}else{
			print("does not scroll")
			self.feedFriends.feedVC.didScroll = false
		}
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
		print("va a aparecer")
	
		let appDelegate = UIApplication.shared.delegate as! AppDelegate
		print("valor de postId(\(String(describing: appDelegate.postID)))")
		print("el valor de Data: \(feedFriends.feedVC.theData)")
		if let postID = appDelegate.postID, let data = feedFriends.feedVC.theData {
			self.pagerVC.selectedIndex = 0
		}
	}
}
