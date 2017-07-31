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

class SearchResultsViewController : UICollectionViewController {
    
    var animals: [AnimalModel]!
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return animals == nil ? 0 : animals.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "reuse", for: indexPath) as! AnimalResultCollectionViewCell
        
        cell.contentView.layer.cornerRadius = 5
        cell.contentView.clipsToBounds = true
        
        let animalData = animals[indexPath.row]
        cell.petNameAge.text = "\(animalData.name!), \(animalData.year!)"
        cell.distance.text = "\(animalData.distance!)km"
        cell.userId = animalData.ownerId
        cell.searchResultViewController = self
        cell.addFriendButton.tag = indexPath.row
        cell.animalPic.kf.setImage(with: animalData.profilePicUrl,
                                   placeholder: nil,
                                   options: [.transition(.fade(1))],
                                   progressBlock: nil,
                                   completionHandler: nil)
        
        
        cell.animalPic.kf.indicatorType = .activity
        
        return cell
    }
    
    @IBAction func friend(_ sender: UIButton) {
        _ = Api.instance.post("/user/\(animals[sender.tag].ownerId!)/friend")
            .then { _ in alert.showAlertSuccess(title: "Succès", subTitle: "Vous avez ajouté un ami") }
            .catch { _ in alert.showAlertError(title: "Erreur", subTitle: "Une erreur est survenue") }
    }
//    @IBAction func friend(_ sender: Any) {
//    }
    
    
    override func viewDidLayoutSubviews() {
        
        let layout = collectionViewLayout as! UICollectionViewFlowLayout
        layout.minimumLineSpacing = 10
        
        let columns = 2
        let itemSpacing: CGFloat = 5
        var itemWidth = collectionView!.frame.width / CGFloat(columns) - (layout.sectionInset.left + layout.sectionInset.right) / CGFloat(columns)
        itemWidth -= itemSpacing
        let itemHeight = CGFloat(300)
        
        layout.itemSize = CGSize(width: itemWidth, height: itemHeight)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let indicator = UIActivityIndicatorView(frame: view.frame)
        indicator.startAnimating()
        indicator.color = .gray
        collectionView?.backgroundView = indicator
        
        Search.instance.callForSearch()
            .then { results -> Void in

                self.collectionView?.backgroundView = nil
                
                let arraySub = results["result"].arrayValue
                
                guard arraySub.count != 0 else {
                    UIKitViewUtils.showLabelInCenter(withText: "Aucun résultat", inView: self.view)
                    return
                }
                
                self.animals = [AnimalModel]()
                
                for byDistance in arraySub {
                    if byDistance[0][0] == JSON.null {
                        continue
                    }
                    self.animals.append(AnimalModel(fromJSON: byDistance[0][0], distance:  Int(byDistance[1].stringValue)!))
                }
                
                if self.animals.count == 0 {
                    self.collectionView?.backgroundView = ViewUseful.instanceFromNib("EmptyTableBG")
                }
                
                self.collectionView?.reloadData()
            }.catch { err in
                UIKitViewUtils.showLabelInCenter(withText: "Erreur de chargement.\nVeuillez réessayer. (\(err))", inView: self.view)
        }
    }
    
    // MARK: - UICollectionViewDelegate protocol
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        // handle tap events
        let animal = animals[indexPath.item]
        let profileVC = AnimalVC.newInstance(animal)
        navigationController?.pushViewController(profileVC, animated: true)
    }
    
    func chat(withUser id: Int) {
        
        let vc = ConversationViewController()
        vc.hidesBottomBarWhenPushed = true
        vc.conversation = ConversationModel()
        vc.conversation.recipient = UserModel()
        vc.conversation.recipient.id = id
        navigationController?.pushViewController(vc, animated: true)
    }
    
}
