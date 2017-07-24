//
//  HistoryList.swift
//  Recognition
//
//  Created by Nikolaus Heger on 5/5/16.
//  Copyright © 2016 Nikolaus Heger. All rights reserved.
//


class HistoryList {
        
    var array:[String] = []
    fileprivate let maxSize = 100
    
    init() {
    }
    
    init(arr:[String]) {
        array = arr
    }
    
    func addItemToHistory(_ obj: String) {
        let ix = array.index(of: obj)
        if let ix = ix {
            array.remove(at: ix)
        }
        while array.count >= maxSize {
            print("max size exceeded - removing last item, adding default back as last item in the list")
            array.removeLast()
        }
        array.insert(obj, at: 0)
    }
    
    func removeItemFromHistory(_ obj: String) {
        let ix = array.index(of: obj)
        if let ix = ix {
            array.remove(at: ix)
        }

    }
    func count() -> Int {
        return array.count
    }
}
