//
//  ClimateViewController.swift
//  HomeAutomation
//
//  Created by Steele on 2016-03-21.
//  Copyright © 2016 11thHourIndustries. All rights reserved.
//

import UIKit

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
    
    var timer = NSTimer()
    var currentNumber = 0
    var previousNumber = 0
    var firstTime = true
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        //Init node controller
        self.nodeManager = NodeManager()
        
        if let baseURLString = NSUserDefaults.standardUserDefaults().objectForKey("baseURLString") as? String
        {
            nodeManager.baseURLString = baseURLString
        }
        
        nameLabel.text = node.name
        addressLabel.text = node.address
        statusLabel.text = node.thermostatMode
        nodeManager.nodeType(node)
        
        currentHumidityLabel.text = node.thermostatHumidity
        currentTempLabel.text = node.thermostatPV
        setpointTempLabel.text = node.thermostatHeatSP
        
        
        print("\(node.thermostatCoolSP)")
        print("\(node.thermostatHeatSP)")
        print("\(node.thermostatMode)")
        print("\(node.thermostatHumidity)")
        print("\(node.thermostatPV)")
        
        //Setup Activity Spinner
        activitySpinner.hidesWhenStopped = true
        
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    /*
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.
    }
    */
    
    
    
    
    @IBAction func upTempButton(sender: AnyObject)
    {
        if firstTime == true
        {
            currentNumber = 0
        }
        
        currentNumber += 2
        timer.invalidate()
        timer = NSTimer.scheduledTimerWithTimeInterval(0.5, target: self, selector: "incControl", userInfo: nil, repeats: false)
        
        if firstTime == true
        {
            firstTime = false
            nodeManager.delay(2) { () -> () in
                
                self.activitySpinner.startAnimating()
                
                if self.previousNumber == self.currentNumber
                {
                    print("done inc \(self.currentNumber)")
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
    
    
    @IBAction func downTempButton(sender: AnyObject)
    {
        if firstTime == true
        {
            currentNumber = 0
        }
        
        currentNumber -= 2
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
        
    }
    
    
    
    
    
    
    
    
    
}
