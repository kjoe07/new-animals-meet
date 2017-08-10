//
//  useful.swift
//  AnimalsMeet
//
//  Created by Adrien morel on 12/9/16.
//  Copyright © 2016 AnimalsMeet. All rights reserved.
//

import Foundation

public extension Date {
    
    public static func dateFromISOString(string: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.timeZone = TimeZone.current
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        
        return dateFormatter.date(from: string)
    }
}
