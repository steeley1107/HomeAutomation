//
//  DashboardCollectionViewController.swift
//  HomeAutomation
//
//  Created by Steele on 2016-05-16.
//  Copyright © 2016 11thHourIndustries. All rights reserved.
//

import UIKit
import RealmSwift

private let reuseIdentifier = "DeviceCell"

class DashboardCollectionViewController: UICollectionViewController {
    
    //Mark - Properties
    var dashboardArray = [Any]()
    var nodeManager: NodeManager!
    var programManager: ProgramManager!
    var sceneManager: SceneManager!
    var updating = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.methodOfReceivedNotification(_:)), name:"NodesReady", object: nil)
        
        //Init node controller
        nodeManager = NodeManager.sharedInstance
        programManager = ProgramManager.sharedInstance
        sceneManager = SceneManager.sharedInstance
        
        refresh(self)
    }
    
    override func viewWillAppear(animated: Bool) {
        
        nodeManager.getStatusAllNodes { (success) in
            self.refresh(self)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     // Get the new view controller using [segue destinationViewController].
     // Pass the selected object to the new view controller.
     }
     */
    
    // MARK: UICollectionViewDataSource
    
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        let count = dashboardArray.count
        return count
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let element = dashboardArray[indexPath.row]
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("DeviceCell", forIndexPath: indexPath) as! DashboardCollectionViewCell
        
        //Setup and Control Activity Spinner
        cell.activitySpinner.hidesWhenStopped = true
        if self.updating == true
        {
            cell.activitySpinner.startAnimating()
        }
        else
        {
            cell.activitySpinner.stopAnimating()
        }
        
        if let node = element as? Node
        {
            cell.title.text = node.name
            cell.status.text = node.status
            
            //Change the color of the status to red or green.
            if node.status == "On"
            {
                cell.status.textColor = UIColor.greenColor()
                //adding icon ending
                cell.image.image = UIImage(named: node.imageName + "-on")
            }
            else
            {
                cell.status.textColor = UIColor.redColor()
                //add icon ending
                cell.image.image = UIImage(named: node.imageName + "-off")
            }
        }
        else if let program = element as? Program
        {
            cell.title.text = program.name
            cell.status.text = program.status
            
            //Change the color of the status to red or green.
            if program.status == "true"
            {
                cell.status.textColor = UIColor.greenColor()
                //adding icon ending
                cell.image.image = UIImage(named: "program" + "-on")
            }
            else
            {
                cell.status.textColor = UIColor.redColor()
                //add icon ending
                cell.image.image = UIImage(named: "program" + "-off")
            }
            
            
        }
        else if let scene = element as? Scene
        {
            cell.title.text = scene.name
            cell.status.text = sceneManager.sceneStatus(scene)
            
            //Change the color of the status to red or green.
            if cell.status.text == "On"
            {
                cell.status.textColor = UIColor.greenColor()
                //adding icon ending
                cell.image.image = UIImage(named: "program" + "-on")
            }
            else
            {
                cell.status.textColor = UIColor.redColor()
                //add icon ending
                cell.image.image = UIImage(named: "program" + "-off")
            }
            
        }
        
        return cell
    }
    
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        updating = true
        
        var indexPathArray = [NSIndexPath]()
        indexPathArray.append(indexPath)
        self.collectionView?.reloadItemsAtIndexPaths(indexPathArray)
        
        if let node = dashboardArray[indexPath.row] as? Node
        {
            var indexPathArray = [NSIndexPath]()
            indexPathArray.append(indexPath)
            if node.status == "On"
            {
                nodeManager.command(node, command: "DFOF", completionHandler: { (success) in
                    self.nodeManager.nodeStatus(node, completionHandler: { (success) in
                        self.updating = false
                        self.collectionView?.reloadItemsAtIndexPaths(indexPathArray)
                    })
                })
            }
            else if node.status == "Off"
            {
                nodeManager.command(node, command: "DFON", completionHandler: { (success) in
                    self.nodeManager.nodeStatus(node, completionHandler: { (success) in
                        self.updating = false
                        self.collectionView?.reloadItemsAtIndexPaths(indexPathArray)
                    })
                })
            }
        }
        
        if let scene = dashboardArray[indexPath.row] as? Scene
        {
            self.updating = false
            self.collectionView?.reloadItemsAtIndexPaths(indexPathArray)
        }
        
        
        if let program = dashboardArray[indexPath.row] as? Program
        {
            var indexPathArray = [NSIndexPath]()
            indexPathArray.append(indexPath)
            
            programManager.programCommand(program, command: "run", completionHandler: { (success) in
                self.programManager.getProgram(program, completionHandler: { (success, program) in
                    self.updating = false
                    self.collectionView?.reloadItemsAtIndexPaths(indexPathArray)
                })
            })
        }
        
    }
    
    
    // MARK: UICollectionViewDelegate
    
    /*
     // Uncomment this method to specify if the specified item should be highlighted during tracking
     override func collectionView(collectionView: UICollectionView, shouldHighlightItemAtIndexPath indexPath: NSIndexPath) -> Bool {
     return true
     }
     */
    
    /*
     // Uncomment this method to specify if the specified item should be selected
     override func collectionView(collectionView: UICollectionView, shouldSelectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
     return true
     }
     */
    
    /*
     // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
     override func collectionView(collectionView: UICollectionView, shouldShowMenuForItemAtIndexPath indexPath: NSIndexPath) -> Bool {
     return false
     }
     
     override func collectionView(collectionView: UICollectionView, canPerformAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) -> Bool {
     return false
     }
     
     override func collectionView(collectionView: UICollectionView, performAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) {
     
     }
     */
    
    
    
    func methodOfReceivedNotification(notification: NSNotification){
        //Take Action on Notification
        refresh(self)
    }
    
    //call this function to update tableview
    func refresh(sender:AnyObject)
    {
        self.dashboardArray = []
        var dashboardRealm:[Any] = self.nodeManager.queryNodesFromRealm()
        dashboardRealm.appendContentsOf(self.programManager.queryNodesFromRealm())
        dashboardRealm.appendContentsOf(self.sceneManager.queryNodesFromRealm())
        self.dashboardArray = dashboardRealm
        
        self.collectionView!.reloadData()
        
    }
    
    
    
}
