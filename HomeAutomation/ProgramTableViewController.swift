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
    
    var programManager: ProgramManager!
    var tableRefreshControl: UIRefreshControl!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Reload tableView
        self.refreshControl = UIRefreshControl()
        self.refreshControl!.attributedTitle = NSAttributedString(string: "Pull to refresh")
        self.refreshControl!.addTarget(self, action: "refresh:", forControlEvents: UIControlEvents.ValueChanged)
        
        //Init node controller
        self.programManager = ProgramManager()
        
        //update tableview
        refresh(self)
        
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
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
            programManager.baseURLString = baseURLString
        }
        
        programManager.addPrograms { (success) -> () in
            if success {
                self.tableView.reloadData()
                self.refreshControl!.endRefreshing()
            }
        }
    }

    
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        
        let count = programManager.programFolders.count
        return count
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        
        let count = programManager.programFolders[section].programArray.count
        return count
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell:NodeListTableViewCell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! NodeListTableViewCell
        
        // Configure the cell...
        let program:Program =  programManager.programFolders[indexPath.section].programArray[indexPath.row]
        
        cell.nodeTitle.text = programManager.programFolders[indexPath.section].programArray[indexPath.row].name
        cell.nodeStatus.text = programManager.programFolders[indexPath.section].programArray[indexPath.row].status
        
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
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return programManager.programFolders[section].name
    }
    
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let selectedProgram = programManager.programFolders[indexPath.section].programArray[indexPath.row] as Program
        
//        if selectedNode.deviceCat.rawValue == 1 || selectedNode.deviceCat.rawValue == 2
//        {
//            performSegueWithIdentifier("Switch", sender: nil)
//            
//        }
//        if selectedNode.deviceCat.rawValue == 5
//        {
//            performSegueWithIdentifier("Climate", sender: nil)
//            
//        }
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
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
