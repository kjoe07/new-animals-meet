//
//  news.swift
//  AnimalsMeet
//
//  Created by Sacha IFRAH on 04/12/2016.
//  Copyright © 2016 AnimalsMeet. All rights reserved.
//

import UIKit
import Floaty

class NewsViewController: UIViewController,UITextFieldDelegate {
    
    lazy var feedVC = FeedViewController(style: .plain)
    lazy var collectionVC = MosaicViewController(collectionViewLayout: UICollectionViewFlowLayout())
    let button = UIButton()
    var isTVC = true
    var endpoint: String!
    
    var searchBar: UISearchBar!
    var containerView: UIView!
    var postId: Int!
    
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
        
        for view in searchBar.subviews{
            if view.isKind(of: UITextField.self){
                (view as! UITextField).delegate = self
            }
        }
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
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
         self.view.endEditing(true)
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        //searchBar.showsCancelButton = true
        let text = searchText.isEmpty ? nil : searchText
        print("el texto a buscar \(String(describing: text))")
        if text == nil {
            print("quito el responder")
            searchBar.resignFirstResponder()
            feedVC.searchTerm = nil
        }
        //feedVC.searchTerm = text
        //feedVC.search(searchFor: text)
        //feedVC.fetchItems(from: <#T##Int#>, count: <#T##Int#>)
        //let _ = feedVC.shouldRefresh()/**/
    }/**/
   func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        print("termino la busqueda")
        let text = (searchBar.text?.isEmpty)! ? nil : searchBar.text
        if text == nil {
            searchBar.resignFirstResponder()
            feedVC.searchTerm = nil
        }
        feedVC.searchTerm = text
        //feedVC.search(searchFor: text!)
        let _ = feedVC.shouldRefresh()
    } /**/
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        print("clear TableVIew")
        //searchBar.showsCancelButton = false
        // Clear any search criteria
        searchBar.text = ""
        feedVC.searchTerm = ""
        searchBar.resignFirstResponder()
        
        // Force reload of table data from normal data source
        self.feedVC.tableView.reloadData()
    }
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        print("el delagado en clear boton")
        searchBar.resignFirstResponder()
        feedVC.searchTerm = nil
        _ = feedVC.shouldRefresh()
        return true
    }

}
