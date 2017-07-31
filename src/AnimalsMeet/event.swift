//
//  logging.swift
//  AnimalsMeet
//
//  Created by Sacha IFRAH on 04/10/2016.
//  Copyright © 2016 AnimalsMeet. All rights reserved.
//

import Foundation
import Crashlytics

class Event {
    
    static func customEvent(name: String, attributes: [String : Any]) {
         Answers.logCustomEvent(withName: name, customAttributes: attributes)
    }
    
    static func trackUser(name: String, contentType: String, contentId: String, attributes: [String : Any]) {
        Answers.logContentView(withName: name, contentType: contentType, contentId: contentId, customAttributes: attributes)

    }
    
    
    static func trackLogin(userId: String, userEmail: String) {
        Answers.logLogin(withMethod: "Digits",
                                   success: true,
                                   customAttributes: [
                                    "User ID": userId,
                                    "User Email": userEmail
            ])
    }
    
    static func trackSignUp(userId: String, userEmail: String) {
        Answers.logSignUp(withMethod: "Digits",
                                    success: true,
                                    customAttributes: [
                                        "User ID": userId,
                                        "User Email": userEmail
                                    ])
    }
    
}
