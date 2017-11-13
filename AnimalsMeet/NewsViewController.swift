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
    var endpoint: String!
    
    var searchBar: UISearchBar!
    var containerView: UIView!
    
    override func viewDidLoad() {
        feedVC.endpoint = endpoint
        collectionVC.endpoint = endpoint
        super.viewDidLoad()
        self.addChildViewController(feedVC)
        self.addChildViewController(collectionVC)
        
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
        
        searchBar = UISearchBar()
        self.view.addSubview(searchBar)
        searchBar.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.left.equalToSuperview()
            make.right.equalToSuperview()
        }
        searchBar.delegate = self
        searchBar.returnKeyType = .done
        
        containerView = UIView()
        self.view.addSubview(containerView)
        containerView.snp.makeConstraints { make in
            make.top.equalTo(searchBar.snp.bottom)
            make.right.equalToSuperview()
            make.left.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        
        feedVC.automaticallyAdjustsScrollViewInsets = false
        collectionVC.automaticallyAdjustsScrollViewInsets = false

        hideKeyboardWhenTappedAround()
        swapControllers()
    }
    
    func swapControllers() {
        if !isTVC {
            feedVC.view.removeFromSuperview()
            searchBar.isHidden = true
            view.addSubview(collectionVC.view)
            collectionVC.view.frame = view.frame
        } else {
            collectionVC.view.removeFromSuperview()
            searchBar.isHidden = false
            containerView.addSubview(feedVC.view)
            feedVC.view.frame = containerView.frame
            self.view.layoutIfNeeded()
        }
        
        self.view.bringSubview(toFront: button)
        isTVC = !isTVC
        setButtonImage(isTVC)
    }
    
    func setButtonImage(_ tvc: Bool) {
        button.setImage(isTVC ? #imageLiteral(resourceName: "list") : #imageLiteral(resourceName: "grid"), for: .normal)
    }
}

extension NewsViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.view.endEditing(true)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        let text = searchText.isEmpty ? nil : searchText
        
        feedVC.searchTerm = text
        //feedVC.fetchItems(from: <#T##Int#>, count: <#T##Int#>)
        let _ = feedVC.shouldRefresh()
    }

}
