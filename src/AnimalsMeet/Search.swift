//
//  SearchModel.swift
//  AnimalsMeet
//
//  Created by Sacha IFRAH on 24/10/2016.
//  Copyright © 2016 AnimalsMeet. All rights reserved.
//

import PromiseKit
import Foundation
import SwiftyJSON
import Cereal

extension Search: CerealType {
    
    func encodeWithCereal( _ cereal: inout CerealEncoder) throws {
        try cereal.encode(dog, forKey: "dog")
        try cereal.encode(cat, forKey: "cat")
        try cereal.encode(female, forKey: "female")
        try cereal.encode(male, forKey: "male")
        try cereal.encode(cross, forKey: "cross")
        try cereal.encode(loof, forKey: "loof")
        try cereal.encode(heat, forKey: "heat")
        try cereal.encode(range, forKey: "range")
        try cereal.encode(breeds, forKey: "breeds")
    }
    
    init(decoder: CerealDecoder) throws {
        dog = try decoder.decode(key: "dog")!
        cat = try decoder.decode(key: "cat")!
        female = try decoder.decode(key: "female")!
        male = try decoder.decode(key: "male")!
        cross = try decoder.decode(key: "cross")!
        loof = try decoder.decode(key: "loof")!
        heat = try decoder.decode(key: "heat")!
        range = try decoder.decode(key: "range")!
        breeds = try decoder.decode(key: "breeds")!
    }
}


struct Search {

    public static var instance: Search = loadFromCache() {
        didSet {
            var encoder = CerealEncoder()
            try? encoder.encode(instance, forKey: "searchData")
            let data = encoder.toData()
            let defaults = UserDefaults.standard
            defaults.set(data, forKey: "searchData")
        }
        
    }
    
    var dog = true
    var cat = true
    var female = true
    var male = true
    var cross = true
    var loof = true
    var heat = true
    var range = 20
    var breeds: [Int] = []

    init() {}
    
    static func loadFromCache() -> Search {
        
        let defaults = UserDefaults.standard
        if let data = defaults.object(forKey: "searchData") as? Data {
            let decoder = try? CerealDecoder(data: data)
            return try! decoder!.decodeCereal(key: "searchData")!
        }
        return Search()
    }
    
    func callForSearch() -> Promise<JSON> {
        
        let parameters = [
            "search": [
                "male": male,
                "femele": female,
                "heat": heat,
                "lof": loof,
                "dog": dog,
                "cat": cat,
                "cross": cross,
                "range_km": range,
                "breed": String(describing: [breeds])
            ]
        ]
        
        return Api.instance.post("/search", withParams: parameters)
    }
    
}
