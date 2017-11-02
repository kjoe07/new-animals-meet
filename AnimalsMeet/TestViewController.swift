//
//  TestViewController.swift
//  AnimalsMeet
//
//  Created by Marilyn on 10/19/17.
//  Copyright © 2017 AnimalsMeet. All rights reserved.
//

import UIKit

class TestViewController: UIViewController {

    @IBOutlet weak var scrollView: OLEContainerScrollView!
    @IBOutlet weak var infoView: UIView!
    
    var tableViews: [UITableView] = []
    var numberOfRows: [Int] = []
    var cellColors: [UIColor] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let numberOfTables = 1
        
        let v = createView(400)
        v.addSubview(infoView)
        infoView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.bottom.equalToSuperview()
            make.left.equalToSuperview()
            make.right.equalToSuperview()
        }
        scrollView.contentView.addSubview(v)
        
        for _ in 0..<numberOfTables {
            let table = createTableView()
            let numberRows = 10 + arc4random_uniform(10)
            tableViews.append(table)
            numberOfRows.append(Int(numberRows))
            cellColors.append(UIColor().random())
            scrollView.contentView.addSubview(table)
            
        }
        
        // Do any additional setup after loading the view.
    }
    
    func createView(_ height: CGFloat) -> UIView {
        var frame = self.view.frame
        frame.size.height = height
        let view = UIView(frame: frame)
        view.backgroundColor = UIColor().random()
        return view
    }
    
    func createTableView() -> UITableView {
        let tableView = UITableView(frame: CGRect(x: 0, y: 0, width: 0, height: 0), style: .plain)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "MyCell")
        tableView.backgroundColor = UIColor.white
        return tableView
    }

}

extension TestViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let index = self.tableViews.index(of: tableView)
        return self.numberOfRows[index!]
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MyCell", for: indexPath)
        let index = self.tableViews.index(of: tableView)
        let color = cellColors[index!]
        cell.backgroundColor = color
        return cell
    }
}

extension UIColor {
    func random() -> UIColor {
        return addHue(CGFloat(arc4random_uniform(256))/255.0, saturation: 1.0, brightness: 1.0, alpha: 1.0)
    }
}
