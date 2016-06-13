//
//  SceneTableViewController.swift
//  HomeAutomation
//
//  Created by Steele on 2016-05-06.
//  Copyright © 2016 11thHourIndustries. All rights reserved.
//

import UIKit

class SceneTableViewController: UITableViewController {
    
    
    
    //Mark: Properties
    
    var array = [Any]()
    var sceneManager: SceneManager!
    var tableRefreshControl: UIRefreshControl!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.methodOfReceivedNotification(_:)), name:"ScenesReady", object: nil)
        
        //Reload tableView
        self.refreshControl = UIRefreshControl()
        //self.refreshControl!.attributedTitle = NSAttributedString(string: "Pull to refresh")
        self.refreshControl!.addTarget(self, action: "refresh:", forControlEvents: UIControlEvents.ValueChanged)
        
        //Init node controller
        self.sceneManager = SceneManager()
        
        
        
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
            sceneManager.baseURLString = baseURLString
        }
        
        sceneManager.addScenes({ (success) in
            if success {
                self.array = []
                self.array = self.sceneManager.array
                self.tableView.reloadData()
                self.refreshControl!.endRefreshing()
            }
        })
    }
    
    func methodOfReceivedNotification(notification: NSNotification){
        //Take Action on Notification
        refresh(self)
    }
    
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        let count = 1
        return count
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let count = array.count
        return count
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let element = array[indexPath.row]
        
        if let scene = element as? Scene
        {
            let cell:NodeTableViewCell = tableView.dequeueReusableCellWithIdentifier("ProgramCell", forIndexPath: indexPath) as! NodeTableViewCell
            
            cell.nodeTitle.text = scene.name
            //cell.nodeStatus.text = scene.status
            
            //Change the color of the status to red or green.
            if cell.nodeStatus.text == "true"
            {
                cell.nodeStatus.textColor = UIColor.greenColor()
                //adding icon ending
                cell.nodeImage.image = UIImage(named: "program" + "-on")
            }
            else
            {
                cell.nodeStatus.textColor = UIColor.redColor()
                //add icon ending
                cell.nodeImage.image = UIImage(named: "program" + "-off")
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
    
    
    //    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    //    {
    //        let selectedElement = array[indexPath.row]
    //
    //        if let program = selectedElement as? Program
    //        {
    //            if program.folder == "true"
    //            {
    //                performSegueWithIdentifier("Folder", sender: nil)
    //            }
    //            else
    //            {
    //                //                if node.deviceCat.rawValue == 1 || node.deviceCat.rawValue == 2
    //                //                {
    //                //                    performSegueWithIdentifier("Switch", sender: nil)
    //                //                }
    //            }
    //        }
    //    }
    
    
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
    {
        if (segue.identifier == "Scene")
        {
            let sceneVC:SceneControlTableViewController = segue.destinationViewController as! SceneControlTableViewController
            let indexPath = tableView.indexPathForSelectedRow
            let selectedScene = array[indexPath!.row] as! Scene
            sceneVC.scene = selectedScene
        }
        
        if (segue.identifier == "Folder")
        {
            let sceneTableVC:SceneTableViewController = segue.destinationViewController as! SceneTableViewController
            let indexPath = tableView.indexPathForSelectedRow
            sceneTableVC.array = sceneManager.loadArray(indexPath!, array: array)
        }
    }
    
    
    
}
