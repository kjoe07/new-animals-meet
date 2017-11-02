//
//  LegendViewController.swift
//  AnimalsMeet
//
//  Created by Marilyn on 9/26/17.
//  Copyright © 2017 AnimalsMeet. All rights reserved.
//

import UIKit

protocol NewLegend {
    func legend(legend: String)
}

class LegendViewController: UIViewController {

    @IBOutlet weak var textView: UITextView!
    var delegate: NewLegend!
    var legend: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textView.text = legend
        textView.becomeFirstResponder()
    }

    @IBAction func stop(_ sender: Any) {
        navigationController?.popViewController(animated: true)
//        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func send(_ sender: UIBarButtonItem) {
        delegate.legend(legend: textView.text)
        navigationController?.popViewController(animated: true)
    }
}
