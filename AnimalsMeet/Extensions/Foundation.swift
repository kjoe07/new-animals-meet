//
//  Foundation.swift
//  AnimalsMeet
//
//  Created by Reynaldo Aguilar on 8/27/17.
//  Copyright © 2017 AnimalsMeet. All rights reserved.
//

import Foundation
import SwiftDate

extension Date {
   var localizedString: String {
      let region = Region(tz: TimeZoneName.europeParis, cal: CalendarName.current, loc: LocaleName.french)
      return try! self.colloquialSinceNow(in: region).colloquial
   }
}

extension UIViewController {
    
    /**
     Setup viewcontroller to hide keyboard when user taps in the view.
     */
    @discardableResult func hideKeyboardWhenTappedAround() -> UIGestureRecognizer {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
        return tap
    }
    
    /**
     Hides the keyboard.
     */
    func dismissKeyboard() {
        view.endEditing(true)
    }
}
extension Array {
	func chunks(_ chunkSize: Int) -> [[Element]] {
		return stride(from: 0, to: self.count, by: chunkSize).map {
			Array(self[$0..<Swift.min($0 + chunkSize, self.count)])
		}
	}
}
