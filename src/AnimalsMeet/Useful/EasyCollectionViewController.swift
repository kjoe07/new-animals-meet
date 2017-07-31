//
//  EasyCollectionViewController.swift
//  AnimalsMeet
//
//  Created by gwendal lasson on 06/06/2017.
//  Copyright © 2017 AnimalsMeet. All rights reserved.
//

import UIKit
import PromiseKit

private let reuseIdentifier = "Cell"

protocol EasyCollectionViewDelegate {
    
    associatedtype DataType
    associatedtype Cell
    
    func fetchItems(from: Int, count: Int) -> Promise<[DataType]>
    func onPopulateCell(item: DataType, cell: Cell)
}

class EasyCollectionViewController<T, C: UICollectionViewCell>: UICollectionViewController, EasyCollectionViewDelegate {
    
    typealias Cell = C
    typealias DataType = T

    let unready = Unready()
    
    func fetchItems(from: Int, count: Int) -> Promise<[T]> {
        return Promise(value: [])
    }
    
    func onPopulateCell(item: T, cell: C) {}
    
    override init(collectionViewLayout layout: UICollectionViewLayout) {
        super .init(collectionViewLayout: layout)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if loadingEnabled {
            indicator.frame = collectionView!.frame
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        collectionView?.backgroundColor = .white
        super.viewDidLoad()
        
        let typeName = String(describing: C.self)
        collectionView!.register(UINib(nibName: typeName, bundle: nil), forCellWithReuseIdentifier: reuseIdentifier)
        initializationIsDone = true
        collectionView!.allowsSelection = false

    }
    
    class BackgroundDescription {
        let title = "Il n'y a rien ici"
        var subtitle: String?
        var image: UIImage?
    }
    
    var theData: [T]!
    var pageSize = 20
    private var initializationIsDone = false
    private var cellReuseIdentifier: String!
    private var bottomWasReached = false
    private lazy var indicator = UIActivityIndicatorView()
    
    private var downloadMethod: Useful.ApiGetter!
    lazy private var backgroundViewWhenDataIsEmpty: UIView = {
        return ViewUseful.instanceFromNib("EmptyTableBG")
    }()
    
    var paginated = true
    
    var pullToRefreshEnabled = false {
        didSet {
            self.collectionView!.addPullRefresh {
                self.shouldRefresh()
                    .always {
                        self.collectionView!.stopPullRefreshEver()
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
                collectionView!.addSubview(indicator)
                indicator.isHidden = false
                indicator.startAnimating()
                indicator.color = .gray
                loadMore()
            }
        }
    }
    private var loading = false
    
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
            self.collectionView!.reloadData()
            }.always {
                self.loading = false
                self.indicator.isHidden = true
                self.indicator.removeFromSuperview()
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        if indexPath.row == theData.count - 1 && !loading && !bottomWasReached {
            _ = shouldLoadMore()
        }
    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func showBackgroundIfEmpty() {
        if collectionView!.backgroundView != nil {
            collectionView!.backgroundView?.removeFromSuperview()
        }
        collectionView!.backgroundView = backgroundViewWhenDataIsEmpty
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if (theData == nil || theData.count == 0) && !loading && initializationIsDone {
            showBackgroundIfEmpty()
        } else {
            collectionView.backgroundView?.removeFromSuperview()
            collectionView.backgroundView = nil
            return theData == nil ? 0 : theData.count
        }
        
        return 0
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
        cell.clipsToBounds = true
        if theData == nil {
            collectionView.reloadData()
            return cell
        }
        
        onPopulateCell(item: theData[indexPath.row], cell: cell as! C)
        return cell
    }

  }
