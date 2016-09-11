//
//  MainTableVC.swift
//  TouchesGaloreTable
//
//  Created by Daniel J Janiak on 9/8/16.
//  Copyright © 2016 Daniel J Janiak. All rights reserved.
//

import UIKit

class MainTableVC: UIViewController {
    
    // MARK: - Properties
    
    var exampleData: [TableItem]!
    
    let placeHolderCell = CustomTableViewCell(style: .Default, reuseIdentifier: "Cell")
    var pullDownInProgress = false
    
    // MARK: - Outlets
    
    @IBOutlet var tableView: UITableView!
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.registerClass(CustomTableViewCell.self, forCellReuseIdentifier: "Cell")
        tableView.separatorStyle = .None
        tableView.rowHeight = 64.0 //49.0
        tableView.backgroundColor = UIColor.blackColor()
        
        
        exampleData = SampleDataGenerator.createSampleData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}


extension MainTableVC: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return exampleData.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! CustomTableViewCell
        
        // cell.textLabel?.backgroundColor = UIColor.clearColor() -- This is accomplished using the StrikethroughText class
        
        // cell.textLabel!.text = exampleData[indexPath.row].cellText -- This is accomplished by using a didSet observer on CustomTableViewCell's toDoItem property.
        
        cell.delegate = self
        cell.toDoItem = exampleData[indexPath.row]
        
        return cell
    }
    
    /* Add color */
    func colorForCellByIndex(index: Int) -> UIColor {
        let cellCount = exampleData.count - 1
        let variableGreen = (CGFloat(index) / CGFloat(cellCount)) * 0.6
        
        return UIColor(red: 1.0, green: variableGreen, blue: 0.0, alpha: 0.85)
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        cell.backgroundColor = colorForCellByIndex(indexPath.row) // UIColor.clearColor()
    }
    
}

// MARK: - UIScrollViewDelegate methods

extension MainTableVC {
    
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        
        pullDownInProgress = scrollView.contentOffset.y <= 0.0
        placeHolderCell.backgroundColor = UIColor.blueColor() //UIColor.redColor()
        if pullDownInProgress {
            /* User has pulled downward at the top of the table, add the placeholder cell */
            tableView.insertSubview(placeHolderCell, atIndex: 0)
        }
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        
        let scrollViewContentOffsetY = scrollView.contentOffset.y
        
        if pullDownInProgress && scrollView.contentOffset.y <= 0.0 {
            /* Re-position the placeholder cell as the user scrolls */
            placeHolderCell.frame = CGRect(x: 0, y: -tableView.rowHeight,
                                           width: tableView.frame.size.width, height: tableView.rowHeight)
            placeHolderCell.label.text = -scrollViewContentOffsetY > tableView.rowHeight ?
                "Release to add item" : "Pull to add item"
            placeHolderCell.alpha = min(1.0, -scrollViewContentOffsetY / tableView.rowHeight)
        } else {
            pullDownInProgress = false
        }
    }
    
    func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        
        /* If the scroll-down gesture was far enough, add the placeholder cell to the collection of items in the table view */
        if pullDownInProgress && -scrollView.contentOffset.y > tableView.rowHeight {
            
            if pullDownInProgress && -scrollView.contentOffset.y > tableView.rowHeight {
                toDoItemAdded()
            }
        }
        pullDownInProgress = false
        placeHolderCell.removeFromSuperview()
    }

}

extension MainTableVC: TableViewCellDelegate {
    
    /* Add a cell */
    func toDoItemAdded() {
        
        let toDoItem = TableItem(text: "")
        exampleData.insert(toDoItem, atIndex: 0)
        tableView.reloadData()
        
        /* Put the new cell into edit mode */
        var editCell: CustomTableViewCell
        let visibleCells = tableView.visibleCells as! [CustomTableViewCell]
        for cell in visibleCells {
            if (cell.toDoItem === toDoItem) {
                
                editCell = cell
                editCell.backgroundColor = UIColor.cyanColor()
                editCell.label.becomeFirstResponder()
                break
            }
        }
    }
    
    /* Delete a cell */
    func toDoItemDeleted(toDoItem: TableItem) {
        
        /* Delete using stock animations only */
        //        let index = (exampleData as NSArray).indexOfObject(toDoItem)
        //        if index == NSNotFound { return }
        //
        //        /* Delete the item from the exampleData array */
        //        exampleData.removeAtIndex(index)
        //
        //        /* Delete the corresponding cell from the table view */
        //        tableView.beginUpdates()
        //        let indexPathForRow = NSIndexPath(forRow: index, inSection: 0)
        //        tableView.deleteRowsAtIndexPaths([indexPathForRow], withRowAnimation: .Left)//.Fade)
        //        tableView.endUpdates()
        
        
        /* Delete a cell, making the cells below it "shuffle" upwards */
        
        let index = (exampleData as NSArray).indexOfObject(toDoItem)
        if index == NSNotFound { return }
        
        // could removeAtIndex in the loop but keep it here for when indexOfObject works
        exampleData.removeAtIndex(index)
        
        let visibleCells = tableView.visibleCells as! [CustomTableViewCell]
        
        /* Kepp track of the last cell */
        let lastView = visibleCells[visibleCells.count - 1] as CustomTableViewCell
        
        var delay = 0.0
        var startAnimating = false
        
        for i in 0..<visibleCells.count {
            
            let cell = visibleCells[i]
            
            if startAnimating {
                
                UIView.animateWithDuration(0.3, delay: delay, options: .CurveEaseInOut,
                                           
                                           animations: {() in
                                            
                                            /* Move the cell up by the distance of a single cell (fills space of the deleted cell)*/
                                            cell.frame = CGRectOffset(cell.frame, 0.0, -cell.frame.size.height)},
                                           
                                           /* Once the animation has been applied to all cells, reload the data */
                                           completion: {(finished: Bool) in
                                            if (cell == lastView) {
                                                self.tableView.reloadData()
                                            }
                    }
                )
                
                delay += 0.03
            }
            
            /* Once the cell to delete has been located, apply the animation to subsequent cells */
            if cell.toDoItem === toDoItem {
                startAnimating = true
                cell.hidden = true
            }
        }
        
        // use the UITableView to animate the removal of this row
        tableView.beginUpdates()
        let indexPathForRow = NSIndexPath(forRow: index, inSection: 0)
        tableView.deleteRowsAtIndexPaths([indexPathForRow], withRowAnimation: .Fade)
        tableView.endUpdates()
    }

    func cellDidBeginEditing(editingCell: CustomTableViewCell) {
        
        print("tableView.contentOffset: \(tableView.contentOffset)")
        
        /* Capture the distance to the VISIBLE top of the table view (i.e. include the scroll position = contentOffset)*/
        let editingOffset = tableView.contentOffset.y - editingCell.frame.origin.y as CGFloat
        
        let visibleCells = tableView.visibleCells as! [CustomTableViewCell]
        
        for cell in visibleCells {
            UIView.animateWithDuration(0.3, animations: {() in
                /* Moves the cell up relative to the scroll position of the table view */
                cell.transform = CGAffineTransformMakeTranslation(0, editingOffset)
                if cell !== editingCell {
                    cell.alpha = 0.3
                }
            })
        }
    }
    
    func cellDidEndEditing(editingCell: CustomTableViewCell) {
        
        let visibleCells = tableView.visibleCells as! [CustomTableViewCell]
        
        for cell: CustomTableViewCell in visibleCells {
            UIView.animateWithDuration(0.3, animations: {() in
                /* A slick way to return the cell to its original spot */
                cell.transform = CGAffineTransformIdentity
                if cell !== editingCell {
                    cell.alpha = 1.0
                }
            })
        }
        
        /* Remove cells that the user leaves blank */
        if editingCell.toDoItem!.cellText == "" {
            toDoItemDeleted(editingCell.toDoItem!)
        }
    }

}
