//
//  ViewController.swift
//  HomeAutomation
//
//  Created by Steele on 2015-12-29.
//  Copyright © 2015 Steele. All rights reserved.
//

import UIKit
import RealmSwift

class SwitchViewController: UIViewController, NSURLSessionDelegate {
    
    
    //Mark: Properties
    var node = Node()
    var nodeManager: NodeManager!
    let realm = try! Realm()
    let gradientLayer = CAGradientLayer()
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var statusIcon: UIImageView!
    @IBOutlet weak var dimSlider: UISlider!
    @IBOutlet weak var dashboardItemStatus: UISwitch!
    
    
    //Mark: Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Init node controller
        self.nodeManager = NodeManager.sharedInstance
        
        if let baseURLString = NSUserDefaults.standardUserDefaults().objectForKey("baseURLString") as? String
        {
            nodeManager.baseURLString = baseURLString
        }
        
        nameLabel.text = node.name
        addressLabel.text = node.address
        
        updateView()
        
        dimSlider.continuous = false
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func onButton(sender: AnyObject)
    {
        nodeManager.command(node, command: "DFON") { (success) in
            if success
            {
                self.updateView()
            }
        }
    }
    
    
    @IBAction func offButton(sender: AnyObject)
    {
        nodeManager.command(node, command: "DFOF") { (success) in
            if success
            {
                self.updateView()
            }
        }
    }
    
    
    @IBAction func dimControl(sender: UISlider)
    {
        let onValue = Int(sender.value)
        nodeManager.onPercentageCommand(node, percent: onValue) { (success) -> () in
            if success
            {
                self.updateView()
            }
        }
    }
    
    
    func updateView()
    {
        let dimOnValue = (self.node.value as NSString).floatValue
        dimSlider.value = dimOnValue
        
        if dimOnValue > 1 && dimOnValue <  254
        {
            statusLabel.text = node.status + "%"
        }
        else
        {
            statusLabel.text = node.status
        }
        if node.status == "Off"
        {
            statusLabel.textColor = UIColor.redColor()
            statusIcon.image = UIImage(named: "Lightbulb-off-icon")
        }
        else if node.status == "On" || dimOnValue > 0
        {
            statusLabel.textColor = UIColor.greenColor()
            statusIcon.image = UIImage(named: "Lightbulb-on-icon")
        }
        
        let predicate = NSPredicate(format: "address = %@", self.node.address)
        let nodeRealm = realm.objects(Node.self).filter(predicate)
        dashboardItemStatus.on = nodeRealm[0].dashboardItem
        
    }
    
    
    @IBAction func dashboardItemSwitch(sender: UISwitch)
    {
        
        let predicate = NSPredicate(format: "address = %@", self.node.address)
        let nodeRealm = realm.objects(Node.self).filter(predicate)
        
        if sender.on
        {
            try! realm.write {
                nodeRealm.setValue(true, forKey: "dashboardItem")
            }
        }
        else
        {
            try! realm.write {
                nodeRealm.setValue(false, forKey: "dashboardItem")
            }
        }
    }
    
}




