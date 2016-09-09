//
//  SampleDataGenerator.swift
//  TouchesGaloreTable
//
//  Created by Daniel J Janiak on 9/8/16.
//  Copyright © 2016 Daniel J Janiak. All rights reserved.
//

import Foundation


class SampleDataGenerator {
    
    
    static func createSampleData() -> [TableItem] {
        
        var toDoItems = [TableItem]()
        
        let sampleList = ["feed the cat", "buy eggs, bread, and milk", "watch WWDC videos", "rule the Web", "study ALL the things!", "finish capstone", "become a Swift ninja", "go for a run", "add more items to this list", "eat watermellon", "have afternoon tea"]
        
        for item in sampleList {
            let newToDo = TableItem(text: item)
            toDoItems.append(newToDo)
        }
        
        return toDoItems
        
    }
}