//
//  MosaicFeedController.swift
//  AnimalsMeet
//
//  Created by gwendal lasson on 06/06/2017.
//  Copyright © 2017 AnimalsMeet. All rights reserved.
//

import UIKit
import SwiftyJSON
import PromiseKit
import Lightbox

class MosaicViewController : EasyCollectionViewController<MediaModel, MosaicCollectionViewCell> {
    var endpoint: String!
    var jsonIndex: String!
    
    override init(collectionViewLayout layout: UICollectionViewLayout) {
        super.init(collectionViewLayout: layout)
        paginated = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        pullToRefreshEnabled = true
        loadingEnabled = true
        paginated = false
        title = "Actualités"
    }
    
    override func fetchItems(from: Int, count: Int) -> Promise<[MediaModel]> {
        return Api.instance.get(endpoint).then { JSON -> [MediaModel] in
            let res = JSON[self.jsonIndex ?? "json"].arrayValue.map { MediaModel(fromJSON: $0) }
            let filter = self.jsonIndex == nil ? res.filter { !$0.isText } : res.filter { !$0.isText && $0.animal != nil }
            
            return filter
        }
    }
    
    func getCellSize() -> CGSize {
        
        let layout = collectionViewLayout as! UICollectionViewFlowLayout
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 1
        layout.sectionInset = UIEdgeInsets.zero
        
        let columns = 3
        let itemSpacing: CGFloat = 1
        var itemWidth = collectionView!.frame.width / CGFloat(columns) - (layout.sectionInset.left + layout.sectionInset.right) / CGFloat(columns)
        itemWidth -= itemSpacing
        let itemHeight = itemWidth
        
        return CGSize(width: itemWidth, height: itemHeight)
    }
    
    override func viewDidLayoutSubviews() {
        
        let layout = collectionViewLayout as! UICollectionViewFlowLayout
        layout.itemSize = getCellSize()
    }
    
    override func onPopulateCell(item: MediaModel, cell: MosaicCollectionViewCell) {
        cell.set(url: item.url)
        
        cell.contentView.onTap { _ in
            presentFullScreen(image: cell.image.image!, onVC: self, media: item)
        }
    }
}

