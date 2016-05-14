//
//  SceneControlTableViewController.swift
//  HomeAutomation
//
//  Created by Steele on 2016-05-09.
//  Copyright © 2016 11thHourIndustries. All rights reserved.
//

import UIKit

class SceneControlTableViewController: UITableViewController {
    
    //Mark: - Properties
    
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var enabledLabel: UILabel!
    @IBOutlet weak var runAtStartupLabel: UILabel!
    @IBOutlet weak var lastRunLabel: UILabel!
    @IBOutlet weak var lastFinishLabel: UILabel!
    @IBOutlet weak var nextRunLabel: UILabel!
    
    var scene = Scene()
    var sceneManager: SceneManager!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Init node controller
        self.sceneManager = SceneManager()
        
        //reload()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        let count = 1
        return count
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        let count = scene.nodeArray.count
        return count
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("NodeCell", forIndexPath: indexPath)
        
        // Configure the cell...
        let element = scene.nodeArray[indexPath.row]
        
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
    
    
    
    
    func reload()
    {
        //        sceneManager.getScene(self.scene) { (success, program) in
        //            if success == true
        //            {
        //                self.statusLabel.text = scene.status
        //                self.enabledLabel.text = scene.enabled
        self.statusLabel.text = scene.name
        //
        //            }
        //
        //        }
        
        
    }
}
