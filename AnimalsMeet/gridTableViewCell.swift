//
//  gridTableViewCell.swift
//  AnimalsMeet
//
//  Created by Yoel JImenez del Valle on 25/12/17.
//  Copyright © 2017 AnimalsMeet. All rights reserved.
//

import UIKit

class gridTableViewCell: UITableViewCell {
	@IBOutlet weak var myCollecttion: UICollectionView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
	func setCollectionViewDataSourceDelegate <D: UICollectionViewDataSource & UICollectionViewDelegate> (dataSourceDelegate: D, forRow row: Int) {
		print("el tag del collection is: \(row)")
		myCollecttion.delegate = dataSourceDelegate
		myCollecttion.dataSource = dataSourceDelegate
		myCollecttion.tag = row
		myCollecttion.reloadData()
	}
}
