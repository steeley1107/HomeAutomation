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
        let count = 2
        return count
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if section == 0 {
            let count = sceneManager.sceneControl.count
            return count
        }
        else
        {
            let count = scene.nodeArray.count
            return count
        }
        
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if indexPath.section == 0
        {
            let cell:SceneControlTableViewCell = tableView.dequeueReusableCellWithIdentifier("SceneControlCell", forIndexPath: indexPath) as! SceneControlTableViewCell
            let element = sceneManager.sceneControl[indexPath.row]
            cell.title.text = element
            return cell
        }
        else
        {
            let element = scene.nodeArray[indexPath.row]
            
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
    }

    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        //Create label and autoresize it
        let headerLabel = UILabel(frame: CGRectMake(10, 20, tableView.frame.width, 2000))
        headerLabel.textColor = UIColor.whiteColor()
        headerLabel.text = "Settings"
        headerLabel.sizeToFit()
        
        //Adding Label to existing headerView
        let headerView = UIView()
        headerView.addSubview(headerLabel)
        headerView.backgroundColor = UIColor.blackColor()
        return headerView
    }

    
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
