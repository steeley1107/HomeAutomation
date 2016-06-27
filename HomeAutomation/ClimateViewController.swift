//
//  ClimateViewController.swift
//  HomeAutomation
//
//  Created by Steele on 2016-03-21.
//  Copyright © 2016 11thHourIndustries. All rights reserved.
//

import UIKit
import RealmSwift

class ClimateViewController: UIViewController {
    
    
    //Mark: Properties
    var node = Node()
    var nodeManager: NodeManager!
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var statusIcon: UIImageView!
    @IBOutlet weak var setpointTempLabel: UILabel!
    @IBOutlet weak var currentTempLabel: UILabel!
    @IBOutlet weak var currentHumidityLabel: UILabel!
    @IBOutlet weak var activitySpinner: UIActivityIndicatorView!
    @IBOutlet weak var dashboardItemStatus: UISwitch!
    
    var timer = NSTimer()
    var currentNumber = 0
    var previousNumber = 0
    var firstTime = true
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        //Init node controller
        self.nodeManager = NodeManager.sharedInstance
        
        if let baseURLString = NSUserDefaults.standardUserDefaults().objectForKey("baseURLString") as? String
        {
            nodeManager.baseURLString = baseURLString
        }
        
        //nodeManager.nodeType(node)
        
        //Update view
        updateView()
        
        //Setup Activity Spinner
        activitySpinner.hidesWhenStopped = true
        
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func upTempButton(sender: AnyObject)
    {
        if firstTime == true
        {
            currentNumber = 0
        }
        currentNumber += 2
        let requestedSP = Int(node.thermostatHeatSP)! + currentNumber / 2
        setpointTempLabel.text = String(requestedSP)
        timer.invalidate()
        timer = NSTimer.scheduledTimerWithTimeInterval(0.5, target: self, selector: "incControl", userInfo: nil, repeats: false)
        
        if firstTime == true
        {
            firstTime = false
            nodeManager.delay(2) { () -> () in
                
                self.activitySpinner.startAnimating()
                
                if self.previousNumber == self.currentNumber
                {
                    self.nodeManager.temperatureChangeCommand(self.node, tempSP: self.currentNumber, completionHandler: { (success) -> () in
                        
                        self.updateView()
                        self.activitySpinner.stopAnimating()
                    })
                }
                self.firstTime = true
            }
        }
    }
    
    
    @IBAction func downTempButton(sender: AnyObject)
    {
        if firstTime == true
        {
            currentNumber = 0
        }
        
        currentNumber -= 2
        let requestedSP = Int(node.thermostatHeatSP)! + currentNumber / 2
        setpointTempLabel.text = String(requestedSP)
        timer.invalidate()
        timer = NSTimer.scheduledTimerWithTimeInterval(0.2, target: self, selector: "incControl", userInfo: nil, repeats: false)
        
        if firstTime == true
        {
            firstTime = false
            nodeManager.delay(2) { () -> () in
                
                self.activitySpinner.startAnimating()
                
                if self.previousNumber == self.currentNumber
                {
                    self.nodeManager.temperatureChangeCommand(self.node, tempSP: self.currentNumber, completionHandler: { (success) -> () in
                        //
                        self.updateView()
                        self.activitySpinner.stopAnimating()
                    })
                }
                self.firstTime = true
            }
        }
    }
    
    
    func incControl()
    {
        previousNumber = currentNumber
    }
    
    
    func updateView()
    {
        nameLabel.text = node.name
        addressLabel.text = node.address
        statusLabel.text = node.thermostatMode
        currentHumidityLabel.text = node.thermostatHumidity
        currentTempLabel.text = node.thermostatPV
        setpointTempLabel.text = node.thermostatHeatSP
        
        //Change the color of the status to red or green.
        if node.thermostatMode == "Heat"
        {
            statusIcon.image = UIImage(named: "flameIcon")
        }
        dashboardItemStatus.on = node.dashboardItem
    }
    
    @IBAction func dashboardItemSwitch(sender: UISwitch)
    {
        let realm = try! Realm()
        
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
