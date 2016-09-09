//
//  TableItem.swift
//  TouchesGaloreTable
//
//  Created by Daniel J Janiak on 9/8/16.
//  Copyright © 2016 Daniel J Janiak. All rights reserved.
//

import UIKit

class TableItem: NSObject {
    
    var cellText: String
    var completed: Bool
    
    init(text: String) {
        self.cellText = text
        self.completed = false        
    }

}
