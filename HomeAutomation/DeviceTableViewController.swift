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
    var array = [Any]()
    
    var tableRefreshControl: UIRefreshControl!
    
    
    
    //Mark:  Load ViewController
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
          NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.methodOfReceivedNotification(_:)), name:"NotificationIdentifier", object: nil)
        
        
        //Reload tableView
        self.refreshControl = UIRefreshControl()
        //self.refreshControl!.attributedTitle = NSAttributedString(string: "Pull to refresh")
        self.refreshControl!.addTarget(self, action: "refresh:", forControlEvents: UIControlEvents.ValueChanged)
        
        //Init node controller
        nodeManager = NodeManager()
        
        //Check to see if values are loaded in the settings screen
        checkSettings()
        
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
                self.array = []
                self.array = self.nodeManager.array
                self.tableView.reloadData()
                self.refreshControl!.endRefreshing()
            }
        }
    }
    
    func methodOfReceivedNotification(notification: NSNotification){
        //Take Action on Notification
        
        refresh(self)
    }
    
    
    
    
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        let count = 1
        return count
    }
    
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        let count = array.count
        return count
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        // Configure the cell...
        let element = array[indexPath.row]
        
        if let node = element as? Node
        {
            let cell:NodeTableViewCell = tableView.dequeueReusableCellWithIdentifier("NodeCell", forIndexPath: indexPath) as! NodeTableViewCell
            
            cell.nodeTitle.text = node.name
            cell.nodeStatus.text = node.status
            
            //Change the color of the status to red or green.
            if cell.nodeStatus.text == "On"
            {
                cell.nodeStatus.textColor = UIColor.greenColor()
                //adding icon ending
                cell.nodeImage.image = UIImage(named: node.imageName + "-on")
            }
            else
            {
                cell.nodeStatus.textColor = UIColor.redColor()
                //add icon ending
                cell.nodeImage.image = UIImage(named: node.imageName + "-off")
            }
            return cell
        }
        else if let element = element as? Folder
        {
            let cell:FolderTableViewCell = tableView.dequeueReusableCellWithIdentifier("FolderCell", forIndexPath: indexPath) as! FolderTableViewCell
            cell.nodeTitle.text = element.name
            return cell
        }
        else
        {
            //Catch all?
            let cell:FolderTableViewCell = tableView.dequeueReusableCellWithIdentifier("FolderCell", forIndexPath: indexPath) as! FolderTableViewCell
            return cell
        }
    }
    
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        let selectedElement = array[indexPath.row]
        
        if let node = selectedElement as? Node
        {
            if node.subnodeArray.count != 0
            {
                performSegueWithIdentifier("Folder", sender: nil)
            }
            else
            {
                if node.deviceCat.rawValue == 1 || node.deviceCat.rawValue == 2
                {
                    performSegueWithIdentifier("Switch", sender: nil)
                }
                if node.deviceCat.rawValue == 5
                {
                    performSegueWithIdentifier("Climate", sender: nil)
                }
            }
        }
    }
    
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
    {
        if (segue.identifier == "Switch")
        {
            let switchVC:SwitchViewController = segue.destinationViewController as! SwitchViewController
            let indexPath = tableView.indexPathForSelectedRow
            let selectedNode = array[indexPath!.row] as! Node
            switchVC.node = selectedNode
        }
        if (segue.identifier == "Climate")
        {
            let climateVC:ClimateViewController = segue.destinationViewController as! ClimateViewController
            let indexPath = tableView.indexPathForSelectedRow
            let selectedNode = array[indexPath!.row] as! Node
            climateVC.node = selectedNode
        }
        
        if (segue.identifier == "Energy")
        {
            let switchVC:SwitchViewController = segue.destinationViewController as! SwitchViewController
            let indexPath = tableView.indexPathForSelectedRow
            let selectedNode = array[indexPath!.row] as! Node
            switchVC.node = selectedNode
        }
        
        if (segue.identifier == "Folder")
        {
            let deviceTableVC:DeviceTableViewController = segue.destinationViewController as! DeviceTableViewController
            let indexPath = tableView.indexPathForSelectedRow
            //array = []
           deviceTableVC.array = nodeManager.loadArray(indexPath!, array: array)
            
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
