//
//  ProgramTableViewController.swift
//  HomeAutomation
//
//  Created by Steele on 2016-04-04.
//  Copyright © 2016 11thHourIndustries. All rights reserved.
//

import UIKit

class ProgramTableViewController: UITableViewController {
    
    //Mark: Properties
    
    var array = [Any]()
    var programManager: ProgramManager!
    var tableRefreshControl: UIRefreshControl!
    var programFolderId = "0001"
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.methodOfReceivedNotification(_:)), name:"ProgramsReady", object: nil)
        
        //Reload tableView
        self.refreshControl = UIRefreshControl()
        //self.refreshControl!.attributedTitle = NSAttributedString(string: "Pull to refresh")
        self.refreshControl!.addTarget(self, action: #selector(ProgramTableViewController.refresh(_:)), forControlEvents: UIControlEvents.ValueChanged)
        
        //Init node controller
        self.programManager = ProgramManager()
        
        refresh(self)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    //call this function to update tableview
    func refresh(sender:AnyObject)
    {
        self.array = []
        self.array = self.programManager.loadArray(programFolderId)
        self.tableView.reloadData()
        self.refreshControl!.endRefreshing()
    }
    
    
    func methodOfReceivedNotification(notification: NSNotification){
        //Take Action on Notification
        refresh(self)
    }
    
    @IBAction func updateRealm(sender: AnyObject)
    {
        programManager.getProgramFolders { (success) in
            self.refresh(self)
        }
        programManager.getPrograms { (success) in
            self.refresh(self)
        }
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
        
        
        
        if let program = element as? Program
        {
            let cell:NodeTableViewCell = tableView.dequeueReusableCellWithIdentifier("ProgramCell", forIndexPath: indexPath) as! NodeTableViewCell
            
            cell.nodeTitle.text = program.name
            cell.nodeStatus.text = program.status
            
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
        else if let programFolder = element as? ProgramFolder
        {
            let cell:FolderTableViewCell = tableView.dequeueReusableCellWithIdentifier("FolderCell", forIndexPath: indexPath) as! FolderTableViewCell
            cell.nodeTitle.text = programFolder.name
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
        
        if let program = selectedElement as? Program
        {
            if program.folder == "true"
            {
                performSegueWithIdentifier("Folder", sender: nil)
            }
            else
            {
                //                if node.deviceCat.rawValue == 1 || node.deviceCat.rawValue == 2
                //                {
                //                    performSegueWithIdentifier("Switch", sender: nil)
                //                }
            }
        }
    }
    
    
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
    {
        if (segue.identifier == "Program")
        {
            let programVC:ProgramControlTableViewController = segue.destinationViewController as! ProgramControlTableViewController
            let indexPath = tableView.indexPathForSelectedRow
            let selectedProgram = array[indexPath!.row] as! Program
            programVC.program = selectedProgram
            programVC.title = selectedProgram.name
        }
        
        if (segue.identifier == "Folder")
        {
            let programTableVC:ProgramTableViewController = segue.destinationViewController as! ProgramTableViewController
            let indexPath = tableView.indexPathForSelectedRow
            
            if let programFolder = array[(indexPath?.row)!] as? ProgramFolder
            {
                print("folder id \(programFolder.id)")
                programTableVC.array = programManager.loadArray(programFolder.id)
                programTableVC.programFolderId = programFolder.id
                programTableVC.title = programFolder.name
                
            }
        }
    }
    
    
}
