//
//  UnreadyViewController.swift
//  AnimalsMeet
//
//  Created by Adrien morel on 01/06/2017.
//  Copyright © 2017 AnimalsMeet. All rights reserved.
//

import UIKit
import PromiseKit

class Unready {

    var promiseReady: Promise<Void>!
    private var fulfill: (() -> ())!
    private var reject: ((Error) -> ())!
    
    init() {
        promiseReady = Promise { fulfill, reject in
            self.fulfill = fulfill
            self.reject = reject
        }
    }
    
    func ready() {
        fulfill()
    }
    
    func fail(withErr err: Error) {
        reject(err)
    }
}
