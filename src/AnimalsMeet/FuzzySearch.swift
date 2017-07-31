//
//  FuzzySearch.swift
//  
//
//  Created by Adrien morel on 12/18/16.
//
//

import Foundation

func fuzzySearch(originalString: String, stringToSearch: String, caseSensitive: Bool = false) -> Bool {
    
    var stringToSearch = stringToSearch
    var originalString = originalString
    if originalString.characters.count == 0 ||
       stringToSearch.characters.count == 0 ||
       originalString.characters.count < stringToSearch.characters.count {
        return false
    }
    
    if !caseSensitive {
        originalString = originalString.lowercased()
        stringToSearch = stringToSearch.lowercased()
    }
    
    var searchIndex : Int = 0
    
    for charOut in originalString.characters {
        for (indexIn,charIn) in stringToSearch.characters.enumerated() {
            if indexIn==searchIndex{
                if charOut==charIn{
                    searchIndex += 1
                    if searchIndex==stringToSearch.characters.count {
                        return true;
                    }
                    else {
                        break
                    }
                }
                else {
                    break
                }
                
            }
        }
    }
    return false;
}
