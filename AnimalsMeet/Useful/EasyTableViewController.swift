//
//  EasyTableViewController.swift
//  app
//
//  Created by Adrien on 5/5/17.
//  Copyright © 2017 ZiggTime. All rights reserved.
//

import UIKit
import PromiseKit
import PullToRefreshSwift

protocol EasyTableViewDelegate {
    
    associatedtype DataType
    associatedtype Cell
    
    func fetchItems(from: Int, count: Int) -> Promise<[DataType]>
    func onPopulateCell(item: DataType, cell: Cell)
}

class EasyTableViewController<T, C: UITableViewCell>: UITableViewController, EasyTableViewDelegate {
    
    typealias Cell = C
    typealias DataType = T
    
    let unready = Unready()
    
    func fetchItems(from: Int, count: Int) -> Promise<[T]> {
        return Promise(value: [])
    }
    
    func onPopulateCell(item: T, cell: C) {}
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let typeName = String(describing: C.self)
        tableView.register(UINib(nibName: typeName, bundle: nil), forCellReuseIdentifier: typeName)
        tableView.tableFooterView = UIView()
        initializationIsDone = true
        tableView.allowsSelection = false
    }
    
    class BackgroundDescription {
        let title = "Il n'y a rien ici"
        var subtitle: String?
        var image: UIImage?
    }
    
    var theData: [T]!
    var pageSize = 20
   /* private*/ var initializationIsDone = false
    /*private */ var cellReuseIdentifier: String!
    /*private */ var bottomWasReached = false
    /*private*/ lazy var indicator = UIActivityIndicatorView()
    
    private var downloadMethod: Useful.ApiGetter!
    lazy private var backgroundViewWhenDataIsEmpty: UIView = {
        return ViewUseful.instanceFromNib("EmptyTableBG")
    }()
    
    var paginated = true

    var pullToRefreshEnabled = false {
        didSet {
            self.tableView.addPullRefresh {
                self.shouldRefresh()
                    .always {
                        self.tableView.stopPullRefreshEver()
                    }.catch { err in
                        self.showBackgroundError(err)
                }
            }
        }
    }

    var loadingEnabled = false {
        didSet {
            if loadingEnabled == true {
                loading = true
                tableView.addSubview(indicator)
                indicator.isHidden = false
                indicator.startAnimating()
                indicator.color = .gray
                loadMore()
            }
        }
    }
    /*private */var loading = false
    
    public func fetchMethod(_ getter: Useful.ApiGetter) {
        downloadMethod = getter
    }
    
    func loadMore() {
        shouldLoadMore().catch { err in
            self.showBackgroundError(err)
        }
    }
    
    private func showBackgroundError(_ err: Error) {
        print(err)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if loadingEnabled {
            indicator.frame = tableView.frame
        }
    }
    
    func shouldRefresh() -> Promise<Void> {
        if theData != nil {
            theData = nil
        }
        return shouldLoadMore()
    }
    
    func shouldLoadMore() -> Promise<Void> {
        
        loading = true
        let dataCount = theData == nil ? 0 : theData.count
        return fetchItems(from: dataCount, count: pageSize).then { items -> () in
            
            self.bottomWasReached = items.count == 0 || (!self.paginated && self.theData != nil)
            
            if self.theData == nil {
                self.theData = []
            }
            
            if self.paginated {
                self.theData.append(contentsOf: items)
            } else {
                self.theData = items
            }
            
            self.loading = false
            self.tableView.reloadData()
            }.always {
                self.loading = false
                self.indicator.isHidden = true
                self.indicator.removeFromSuperview()
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if (theData == nil || theData.count == 0) && !loading && initializationIsDone {
            showBackgroundIfEmpty()
        } else {
            tableView.backgroundView?.removeFromSuperview()
            tableView.backgroundView = nil
            return theData == nil ? 0 : theData.count
        }
 
        return 0
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        if theData != nil && indexPath.row == theData.count - 1 && !loading && !bottomWasReached {
             _ = shouldLoadMore()
        }
    }
 
    func showBackgroundIfEmpty() {
        if tableView.backgroundView != nil {
            tableView.backgroundView?.removeFromSuperview()
        }
        tableView.backgroundView = backgroundViewWhenDataIsEmpty
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: C.self))!
        
        if theData == nil {
            tableView.reloadData()
            return cell
        }
        
        onPopulateCell(item: theData[indexPath.row], cell: cell as! C)
        return cell
    }
}
