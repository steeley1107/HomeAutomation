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
        
        //Check to see if values are loaded in the settings screen
        checkSettings()
        
        //update tableview
        refresh(self)
        
        
        
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
    
    
    //call this function to update tableview
    func refresh(sender:AnyObject)
    {
        if let baseURLString = NSUserDefaults.standardUserDefaults().objectForKey("baseURLString") as? String
        {
            nodeManager.baseURLString = baseURLString
        }
        
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
        
        //let count = nodeManager.folders.count
        let count = 1
        return count
    }
    
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        
        
        //                if section == 0
        //                {
        //                    let count = nodeManager.rootfolder.subfolderArray.count // folders[section].nodeArray.count
        //                    return count
        //                }
        //                else
        //                {
        //                    let count = nodeManager.rootfolder.nodeArray.count
        //                    return count
        //                }
        
        let count = nodeManager.array.count
        return count
        
        
        
        
        
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell:NodeListTableViewCell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! NodeListTableViewCell
        
        // Configure the cell...
        //let node:Node // =  nodeManager.rootfolder.subfolderArray[indexPath.section].nodeArray[indexPath.row]
        
//        if indexPath.section == 0
//        {
//            let folder = nodeManager.rootfolder.subfolderArray[indexPath.row]
//            cell.nodeTitle.text = folder.name
//            return cell
//        }
//        else
//        {
//            let node = nodeManager.rootfolder.nodeArray[indexPath.row]
//            
//            cell.nodeTitle.text = node.name
//            cell.nodeStatus.text = node.status
//            
//            //Change the color of the status to red or green.
//            if cell.nodeStatus.text == "On"
//            {
//                cell.nodeStatus.textColor = UIColor.greenColor()
//                //adding icon ending
//                cell.nodeImage.image = UIImage(named: node.imageName + "-on")
//            }
//            else
//            {
//                cell.nodeStatus.textColor = UIColor.redColor()
//                //add icon ending
//                cell.nodeImage.image = UIImage(named: node.imageName + "-off")
//            }
//            
//            
//            
//            return cell
//        }
        
        
        let element = nodeManager.array[indexPath.row]
        if let element = element as? Node
        {
            cell.nodeTitle.text = element.name
        }
        else if let element = element as? Folder
        {
        cell.nodeTitle.text = element.name
        }
        
        return cell
        
        
    }
    
    
    //    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    //        return nodeManager.folders[section].name
    //    }
    
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let selectedNode = nodeManager.folders[indexPath.section].nodeArray[indexPath.row] as Node
        
        if indexPath.section == 0
        {
            let selectedNode = nodeManager.folders[indexPath.section].nodeArray[indexPath.row] as Node
        }
        
        
        
        
        
        
        if selectedNode.deviceCat.rawValue == 1 || selectedNode.deviceCat.rawValue == 2
        {
            performSegueWithIdentifier("Switch", sender: nil)
            
        }
        if selectedNode.deviceCat.rawValue == 5
        {
            performSegueWithIdentifier("Climate", sender: nil)
            
        }
    }
    
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        //Create label and autoresize it
        let headerLabel = UILabel(frame: CGRectMake(10, 5, tableView.frame.width, 2000))
        headerLabel.textColor = UIColor.whiteColor()
        headerLabel.text = self.tableView(self.tableView, titleForHeaderInSection: section)
        headerLabel.sizeToFit()
        
        //Adding Label to existing headerView
        let headerView = UIView()
        headerView.addSubview(headerLabel)
        headerView.backgroundColor = UIColor.blackColor()
        return headerView
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
    
    
    
    //Alert Controller for the errand manager
    func showAlert(title: String, message: String) {
        
        // create the alert
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        
        // add an action (button)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
        
        // show the alert
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    
    //Check to see if there are user settings
    func checkSettings()
    {
        let userSettings = Array(NSUserDefaults.standardUserDefaults().dictionaryRepresentation().keys).count
        
        if userSettings < 10
        {
            showAlert("Error", message: "Please add information in the settings")
        }
        else
        {
            if let userName = NSUserDefaults.standardUserDefaults().objectForKey("userName") as? String
            {
                if userName.characters.count == 0
                {
                    showAlert("Error", message: "Missing Username")
                }
            }
            if let userName = NSUserDefaults.standardUserDefaults().objectForKey("password") as? String
            {
                if userName.characters.count == 0
                {
                    showAlert("Error", message: "Missing Password")
                }
            }
            if let userName = NSUserDefaults.standardUserDefaults().objectForKey("localIP") as? String
            {
                if userName.characters.count == 0
                {
                    showAlert("Error", message: "Missing local IP")
                }
            }
            if let userName = NSUserDefaults.standardUserDefaults().objectForKey("localPort") as? String
            {
                if userName.characters.count == 0
                {
                    showAlert("Error", message: "Missing Local Port")
                }
            }
            if let userName = NSUserDefaults.standardUserDefaults().objectForKey("secureIP") as? String
            {
                if userName.characters.count == 0
                {
                    showAlert("Error", message: "Missing Secure IP")
                }
            }
            if let userName = NSUserDefaults.standardUserDefaults().objectForKey("securePort") as? String
            {
                if userName.characters.count == 0
                {
                    showAlert("Error", message: "Missing Secure Port")
                }
            }
        }
    }
    
    
    
    
    
}
