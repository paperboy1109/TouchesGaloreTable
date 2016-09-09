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
        
        cell.textLabel?.backgroundColor = UIColor.clearColor()
        
        cell.textLabel!.text = exampleData[indexPath.row].cellText
        
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
