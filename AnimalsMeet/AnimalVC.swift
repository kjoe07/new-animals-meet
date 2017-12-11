//
//  AnimalVC.swift
//  AnimalsMeet
//
//  Created by Yoel JImenez del Valle on 8/12/17.
//  Copyright © 2017 AnimalsMeet. All rights reserved.
//

import UIKit
import LFTwitterProfile
class AnimalVC: TwitterProfileViewController {

    var tweetTableView: UITableView!
    var photosTableView: UITableView!
    var favoritesTableView: UITableView!
    
    var custom: UIView!
    var label: UILabel!
    let button = UIButton()
    var isTVC = false
    var animal: AnimalModel!
    var user: UserModel!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //self.locationString = "Hong Kong"
        //self.username = "memem"
        
        //self.profileImage = UIImage.init(named: "icon.png")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    override func numberOfSegments() -> Int {
        return 2
    }
    
    override func segmentTitle(forSegment index: Int) -> String {
        switch index {
        case 0:
            return "Photos"
        case 1:
            return "Posts"
        default:
            return ""
        }
    }
    
    override func prepareForLayout() {
        // TableViews
        let _tweetTableView = UITableView(frame: CGRect.zero, style: .plain)
        self.tweetTableView = _tweetTableView
        
        let _photosTableView = UITableView(frame: CGRect.zero, style: .plain)
        self.photosTableView = _photosTableView
        
        let _favoritesTableView = UITableView(frame: CGRect.zero, style: .plain)
        self.favoritesTableView = _favoritesTableView
        
        self.setupTables()
    }
    
    
    
    override func scrollView(forSegment index: Int) -> UIScrollView {
        switch index {
        case 0:
            return tweetTableView
        case 1:
            return photosTableView
        case 2:
            return favoritesTableView
        default:
            return tweetTableView
        }
    }
   override func prepareViews() {
    
        let _mainScrollView = TouchRespondScrollView(frame: self.view.bounds)
        _mainScrollView.delegate = self
        _mainScrollView.showsHorizontalScrollIndicator = false
        
        self.mainScrollView  = _mainScrollView
        
        self.view.addSubview(_mainScrollView)
        
        _mainScrollView.snp.makeConstraints { (make) in
            make.edges.equalTo(self.view)
        }
        
        // sticker header Container view
        let _stickyHeaderContainer = UIView()
        _stickyHeaderContainer.clipsToBounds = true
        _mainScrollView.addSubview(_stickyHeaderContainer)
        self.stickyHeaderContainerView = _stickyHeaderContainer
        
        // Cover Image View
        let coverImageView = UIImageView()
        coverImageView.clipsToBounds = true
        _stickyHeaderContainer.addSubview(coverImageView)
        coverImageView.snp.makeConstraints { (make) in
            make.edges.equalTo(_stickyHeaderContainer)
        }
        
        coverImageView.image = UIImage(named: "background.png")
        coverImageView.contentMode = .scaleAspectFill
        coverImageView.clipsToBounds = true
        self.headerCoverView = coverImageView
        
        // blur effect on top of coverImageView
        let blurEffect = UIBlurEffect(style: .dark)
        let _blurEffectView = UIVisualEffectView(effect: blurEffect)
        _blurEffectView.alpha = 0
        self.blurEffectView = _blurEffectView
        
        _stickyHeaderContainer.addSubview(_blurEffectView)
        _blurEffectView.snp.makeConstraints { (make) in
            make.edges.equalTo(_stickyHeaderContainer)
        }
        
        // Detail Title
        let _navigationDetailLabel = UILabel()
        _navigationDetailLabel.text = "121 Tweets"
        _navigationDetailLabel.textColor = UIColor.white
        _navigationDetailLabel.font = UIFont.boldSystemFont(ofSize: 13.0)
        _stickyHeaderContainer.addSubview(_navigationDetailLabel)
        _navigationDetailLabel.snp.makeConstraints { (make) in
            make.centerX.equalTo(_stickyHeaderContainer.snp.centerX)
            make.bottom.equalTo(_stickyHeaderContainer.snp.bottom).inset(8)
        }
        self.navigationDetailLabel = _navigationDetailLabel
        
        // Navigation Title
        let _navigationTitleLabel = UILabel()
        _navigationTitleLabel.text = self.username ?? "{username}"
        _navigationTitleLabel.textColor = UIColor.white
        _navigationTitleLabel.font = UIFont.boldSystemFont(ofSize: 17.0)
        _stickyHeaderContainer.addSubview(_navigationTitleLabel)
        _navigationTitleLabel.snp.makeConstraints { (make) in
            make.centerX.equalTo(_stickyHeaderContainer.snp.centerX)
            make.bottom.equalTo(_navigationDetailLabel.snp.top).offset(4)
        }
        self.navigationTitleLabel = _navigationTitleLabel
        
        // preset the navigation title and detail at progress=0 position
        animateNaivationTitleAt(progress: 0)
        
        // ProfileHeaderView
    Bundle.init(for: AnimalVC.self)
    /*if let url = bundle.url(forResource: "LFTwitterProfile", withExtension: "bundle") {
        return Bundle.init(url: url)
    }*/

        
    if let _profileHeaderView = Bundle.init(for: AnimalVC.self).loadNibNamed("headerView", owner: self, options: nil)?.first as? headerView{
            _mainScrollView.addSubview(_profileHeaderView)
            self.profileHeaderView = _profileHeaderView
            
            //self.profileHeaderView.usernameLabel.text = self.username
            //self.profileHeaderView.locationLabel.text = self.locationString
            //self.profileHeaderView.iconImageView.image = self.profileImage
        }
        
        
        // Segmented Control Container
        let _segmentedControlContainer = UIView.init(frame: CGRect.init(x: 0, y: 0, width: mainScrollView.bounds.width, height: 100))
        _segmentedControlContainer.backgroundColor = UIColor.white
        _mainScrollView.addSubview(_segmentedControlContainer)
        self.segmentedControlContainer = _segmentedControlContainer
        
        // Segmented Control
        let _segmentedControl = UISegmentedControl()
        _segmentedControl.addTarget(self, action: #selector(self.segmentedControlValueDidChange(sender:)), for: .valueChanged)
        _segmentedControl.backgroundColor = UIColor.white
        
        for index in 0..<numberOfSegments() {
            let segmentTitle = self.segmentTitle(forSegment: index)
            _segmentedControl.insertSegment(withTitle: segmentTitle, at: index, animated: false)
        }
        _segmentedControl.selectedSegmentIndex = 0
        _segmentedControlContainer.addSubview(_segmentedControl)
        
        self.segmentedControl = _segmentedControl
        
        _segmentedControl.snp.makeConstraints { (make) in
            //      make.edges.equalTo(_segmentedControlContainer).inset(UIEdgeInsetsMake(8, 16, 8, 16))
            make.width.equalToSuperview().offset(-16)
            make.centerX.equalToSuperview()
            make.centerY.equalTo(_segmentedControlContainer.snp.centerY)
        }
        
        self.scrollViews = []
        for index in 0..<numberOfSegments() {
            let scrollView = self.scrollView(forSegment: index)
            self.scrollViews.append(scrollView)
            scrollView.isHidden = (index > 0)
            _mainScrollView.addSubview(scrollView)
        }
        
        self.showDebugInfo()
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
extension AnimalVC: UITableViewDelegate, UITableViewDataSource {
    
    fileprivate func setupTables() {
        self.tweetTableView.delegate = self
        self.tweetTableView.dataSource = self
        self.tweetTableView.register(UITableViewCell.self, forCellReuseIdentifier: "tweetCell")
        
        self.photosTableView.delegate = self
        self.photosTableView.dataSource = self
        //self.photosTableView.isHidden = true
        self.photosTableView.register(UITableViewCell.self, forCellReuseIdentifier: "photoCell")
        
        self.favoritesTableView.delegate = self
        self.favoritesTableView.dataSource = self
        //self.favoritesTableView.isHidden = true
        self.favoritesTableView.register(UITableViewCell.self, forCellReuseIdentifier: "favCell")
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch tableView {
        case self.tweetTableView:
            return 30
        case self.photosTableView:
            return 10
        case self.favoritesTableView:
            return 50
        default:
            return 10
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch tableView {
        case self.tweetTableView:
            let cell = tableView.dequeueReusableCell(withIdentifier: "tweetCell", for: indexPath)
            cell.textLabel?.text = "Row \(indexPath.row)"
            return cell
            
        case self.photosTableView:
            let cell = tableView.dequeueReusableCell(withIdentifier: "photoCell", for: indexPath)
            cell.textLabel?.text = "Photo \(indexPath.row)"
            return cell
            
        case self.favoritesTableView:
            let cell = tableView.dequeueReusableCell(withIdentifier: "favCell", for: indexPath)
            cell.textLabel?.text = "Fav \(indexPath.row)"
            return cell
            
        default:
            return UITableViewCell()
        }
    }
}
