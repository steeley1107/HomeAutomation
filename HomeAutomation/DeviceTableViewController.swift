//
//  DeviceTableViewController.swift
//  HomeAutomation
//
//  Created by Steele on 2016-02-19.
//  Copyright © 2016 Steele. All rights reserved.
//

import UIKit
import SWXMLHash
import Foundation

class DeviceTableViewController: UITableViewController, NSXMLParserDelegate, NSURLSessionDelegate {
    
    //Mark: Properties
    
    var xml: XMLIndexer?
    var nodeManager: NodeManager!
    
    var tableRefreshControl: UIRefreshControl!
    
    //var refreshControl: UIRefreshControl!
    
    
    
    //Mark:  Load ViewController
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Reload tableView
        self.refreshControl = UIRefreshControl()
        self.refreshControl!.attributedTitle = NSAttributedString(string: "Pull to refresh")
        self.refreshControl!.addTarget(self, action: "refresh:", forControlEvents: UIControlEvents.ValueChanged)
        
        //Init node controller
        self.nodeManager = NodeManager()
        
        if let baseURLString = NSUserDefaults.standardUserDefaults().objectForKey("baseURLString") as? String
        {
            nodeManager.baseURLString = baseURLString
        }
        
        nodeManager.addNodes { (success) -> () in
            if success {
                self.tableView.reloadData()
            }
        }
        
        
        
        //Update tableView with pulldown
        //        self.refreshControl = UIRefreshControl()
        //        self.refreshControl.addTarget(self, action: "refresh:", forControlEvents: UIControlEvents.ValueChanged)
        //        self.tableView.addSubview(refreshControl)
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        
        self.tableView.reloadData()
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func refresh(sender:AnyObject)
    {
        nodeManager.addNodes { (success) -> () in
            if success {
                self.tableView.reloadData()
                self.refreshControl!.endRefreshing()
            }
        }
    }
    
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        
        let count = nodeManager.folders.count
        //print("count \(count)")
        return count
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        let count = nodeManager.folders[section].nodeArray.count
        return count
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        var cell:NodeListTableViewCell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! NodeListTableViewCell
        
        // Configure the cell...
        var node:Node =  nodeManager.folders[indexPath.section].nodeArray[indexPath.row]
        
        cell.nodeTitle.text = nodeManager.folders[indexPath.section].nodeArray[indexPath.row].name
        cell.nodeStatus.text = nodeManager.folders[indexPath.section].nodeArray[indexPath.row].status
       
        
        //Change the color of the status to red or green.
        if cell.nodeStatus.text == "Off"
        {
            cell.nodeStatus.textColor = UIColor.redColor()
            
            
            //adding icon ending
            
            cell.nodeImage.image = UIImage(named: node.imageName)
            
            cell.nodeImage.image = UIImage(named: "Lightbulb-off-icon")
        }
        else if cell.nodeStatus.text == "On"
        {
            cell.nodeStatus.textColor = UIColor.greenColor()
            cell.nodeImage.image = UIImage(named: "Lightbulb-on-icon")
        }
        
        return cell
    }
    
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return nodeManager.folders[section].name
    }
    
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let selectedNode = nodeManager.folders[indexPath.section].nodeArray[indexPath.row] as Node
        
        if selectedNode.deviceCat.rawValue == 1 || selectedNode.deviceCat.rawValue == 2
        {
            performSegueWithIdentifier("Switch", sender: nil)
            
        }
        if selectedNode.deviceCat.rawValue == 5
        {
            performSegueWithIdentifier("Climate", sender: nil)
            
        }
    }
    
    
    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
    // Return false if you do not want the specified item to be editable.
    return true
    }
    */
    
    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
    if editingStyle == .Delete {
    // Delete the row from the data source
    tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
    } else if editingStyle == .Insert {
    // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }
    }
    */
    
    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {
    
    }
    */
    
    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
    // Return false if you do not want the item to be re-orderable.
    return true
    }
    */
    
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
    {
        if (segue.identifier == "Switch")
        {
            let switchVC:SwitchViewController = segue.destinationViewController as! SwitchViewController
            // let selectedIndex = self.tableView.indexPathForCell(sender as! UITableViewCell)
            let indexPath = tableView.indexPathForSelectedRow
            let selectedNode = nodeManager.folders[indexPath!.section].nodeArray[indexPath!.row] as Node
            switchVC.node = selectedNode
        }
        if (segue.identifier == "Climate")
        {
            let climateVC:ClimateViewController = segue.destinationViewController as! ClimateViewController
            // let selectedIndex = self.tableView.indexPathForCell(sender as! UITableViewCell)
            let indexPath = tableView.indexPathForSelectedRow
            let selectedNode = nodeManager.folders[indexPath!.section].nodeArray[indexPath!.row] as Node
            climateVC.node = selectedNode
        }

        if (segue.identifier == "Energy")
        {
            let switchVC:SwitchViewController = segue.destinationViewController as! SwitchViewController
            // let selectedIndex = self.tableView.indexPathForCell(sender as! UITableViewCell)
            let indexPath = tableView.indexPathForSelectedRow
            let selectedNode = nodeManager.folders[indexPath!.section].nodeArray[indexPath!.row] as Node
            switchVC.node = selectedNode
        }
    }
    
    
}
