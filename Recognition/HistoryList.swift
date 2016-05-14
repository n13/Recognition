//
//  HistoryList.swift
//  Recognition
//
//  Created by Nikolaus Heger on 5/5/16.
//  Copyright © 2016 Nikolaus Heger. All rights reserved.
//


class HistoryList {
        
    var array:[String] = []
    private let maxSize = 100
    
    init() {
    }
    
    init(arr:[String]) {
        array = arr
    }
    
    func addItemToHistory(obj: String) {
        let ix = array.indexOf(obj)
        if let ix = ix {
            array.removeAtIndex(ix)
        }
        while array.count >= maxSize {
            print("max size exceeded - removing last item, adding default back as last item in the list")
            array.removeLast()
        }
        array.insert(obj, atIndex: 0)
    }
    
    func removeItemFromHistory(obj: String) {
        let ix = array.indexOf(obj)
        if let ix = ix {
            array.removeAtIndex(ix)
        }

    }
    func count() -> Int {
        return array.count
    }
}