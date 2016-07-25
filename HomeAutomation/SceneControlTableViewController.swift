//
//  SceneControlTableViewController.swift
//  HomeAutomation
//
//  Created by Steele on 2016-05-09.
//  Copyright © 2016 11thHourIndustries. All rights reserved.
//

import UIKit
import RealmSwift

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
        let count = 3
        return count
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if section == 0 {
            let count = sceneManager.sceneControl.count
            return count
        }
        else if section == 1
        {
            let count = scene.members.count
            return count
        }else if section == 2
        {
            let count = 1
            return count
        }
        return 0
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let realm = try! Realm()
        
        if indexPath.section == 0
        {
            let cell:SceneControlTableViewCell = tableView.dequeueReusableCellWithIdentifier("SceneControlCell", forIndexPath: indexPath) as! SceneControlTableViewCell
            let element = sceneManager.sceneControl[indexPath.row]
            cell.title.text = element
            return cell
        }
        else if indexPath.section == 1
        {
            let element = scene.members[indexPath.row]
            
            if let node = element as? Node
            {
                let cell:NodeTableViewCell = tableView.dequeueReusableCellWithIdentifier("SceneCell", forIndexPath: indexPath) as! NodeTableViewCell
                
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
        }else
        {
            let cell:DashboardTableViewCell = tableView.dequeueReusableCellWithIdentifier("DashboardCell", forIndexPath: indexPath) as! DashboardTableViewCell
            
            cell.dashboardItemStatus.on = scene.dashboardItem
            
            if cell.dashboardItemStatus.on
            {
                //Save to Realm
                try! realm.write({
                    scene.dashboardItem = true
                })
            }
            else
            {
                try! realm.write({ 
                    scene.dashboardItem = false
                })
            }
            return cell
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        if indexPath.section == 0
        {
            //select which program to run.
            switch indexPath.row {
            case 0:
                sceneManager.sceneCommand(scene, command: "DFON", completionHandler: { (success) in
                    if success {
                        print("on")
                        self.reload()
                    }
                })
            case 1:
                sceneManager.sceneCommand(scene, command: "DFOF", completionHandler: { (success) in
                    if success {
                        print("off")
                        self.reload()
                    }
                })
            default:
                print("unknown command")
            }
        }
        else if indexPath.section == 1
        {
            let node = scene.members[indexPath.row]
            
            if node.deviceCat == 1 || node.deviceCat == 2
            {
                performSegueWithIdentifier("Switch", sender: nil)
            }
            if node.deviceCat == 5
            {
                performSegueWithIdentifier("Climate", sender: nil)
            }
        }
        else if indexPath.section == 2
        {
            let cell:DashboardTableViewCell = tableView.dequeueReusableCellWithIdentifier("DashboardCell", forIndexPath: indexPath) as! DashboardTableViewCell
            cell.dashboardItemStatus.on = scene.dashboardItem 
        }
    }
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        //Create label and autoresize it
        let headerLabel = UILabel(frame: CGRectMake(10, 5, tableView.frame.width, 2000))
        headerLabel.textColor = UIColor.whiteColor()
   
        if section == 0
        {
            headerLabel.text = "Controls"
        }
        else if section == 1
        {
            headerLabel.text = "Members"
        }
        else if section == 2
        {
            headerLabel.text = "Dashboard"
        }
        headerLabel.sizeToFit()
        
        //Adding Label to existing headerView
        let headerView = UIView()
        headerView.addSubview(headerLabel)
        headerView.backgroundColor = UIColor.blackColor()
        
        
        return headerView
    }
    
    
    func reload()
    {
        self.tableView.reloadData()
        
        //        sceneManager.getScene(self.scene) { (success, program) in
        //            if success == true
        //            {
        //                self.statusLabel.text = scene.status
        //                self.enabledLabel.text = scene.enabled
        //self.statusLabel.text = scene.name
        //
        //            }
        //
        //        }
        
        
    }
    
    
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
    {
        if (segue.identifier == "Switch")
        {
            let switchVC:SwitchViewController = segue.destinationViewController as! SwitchViewController
            let indexPath = tableView.indexPathForSelectedRow
            let selectedNode = scene.members[indexPath!.row] //as! Node
            switchVC.node = selectedNode
        }
        if (segue.identifier == "Climate")
        {
            let climateVC:ClimateViewController = segue.destinationViewController as! ClimateViewController
            let indexPath = tableView.indexPathForSelectedRow
            let selectedNode = scene.members[indexPath!.row] //as! Node
            climateVC.node = selectedNode
        }
        
        if (segue.identifier == "Energy")
        {
            let switchVC:SwitchViewController = segue.destinationViewController as! SwitchViewController
            let indexPath = tableView.indexPathForSelectedRow
            let selectedNode = scene.members[indexPath!.row] //as! Node
            switchVC.node = selectedNode
        }
    }
    
    
    
    
}
