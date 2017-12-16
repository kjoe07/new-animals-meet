//
//  dateUtils.swift
//  vasoking
//
//  Created by kjoe on 9/9/17.
//  Copyright © 2017 Kjoe Inc. All rights reserved.
//

import Foundation
import UIKit
class dateUtil{
    let formatter = DateFormatter()
    static let instance = dateUtil()
    init() {
        formatter.locale = NSLocale(localeIdentifier: "es_ES") as Locale!
    }
    func strinToDate(date:String) -> String{
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        let date = formatter.date(from: date)!
        formatter.dateFormat = "dd 'de' MMMM 'de' yyyy"
        return formatter.string(from: date)
    }
    func timeToDate(time:String) -> String{
        formatter.dateFormat = "HH:mm"
        let time: Date = formatter.date(from: time)!
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: time)
    }
    func stringToDateShort(date: String)-> String{
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        let date = formatter.date(from: date)!
        formatter.dateFormat = "dd'/'MM'/'yyyy"
        return formatter.string(from: date)
    }
    func fullStringToTime(date:String) -> String {
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        let date = formatter.date(from: date)!
        formatter.dateFormat = "hh:mm a"
        return formatter.string(from: date)
    }
    func dateToString() -> String{
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        return formatter.string(from: Date())
    }
}
