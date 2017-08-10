//
//  MosaicPictures.swift
//  AnimalsMeet
//
//  Created by Sacha IFRAH on 04/12/2016.
//  Copyright © 2016 AnimalsMeet. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON
import Kingfisher

class MosaicPictures : UICollectionViewController {
    
    let reuseIdentifier = "cell"
    var items : JSON = [];
    var editAnimalModel:AnimalModel? = nil
    var url: URL!
    var profile: UIImageView!
    
    // MARK: - UICollectionViewDataSource protocol
    
    // tell the collection view how many cells to make
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.items.count
    }
    
    // make a cell for each cell index path
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! MosaicPicturesCell
        
        let id = items[indexPath.row]["id"].stringValue
        let url = App.getImageUrlFromMediaId(Int(id)!)
        cell.img.kf.indicatorType = .activity
        cell.img.kf.setImage(with: url,
                                 placeholder: nil,
                                 options: [.transition(.fade(1))],
                                 progressBlock: nil,
                                 completionHandler: nil);
       
        return cell
    }
    
    override func viewDidLoad() {}
    
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
    
    // MARK: - UICollectionViewDelegate protocol
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "showCell", sender: indexPath.item)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "showCell") {
            /*
            let target = segue.destination as! ListPictures
            let json = items //JSON([items[sender as! Int]])
            target.items = json
            let indexPath = IndexPath(row: sender as! Int, section: 0)
            print ("=============")
            print(indexPath.row)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                target.tableView.scrollToRow(at: indexPath, at: .bottom, animated:false)
            }
 */
            
        }
    }
}
