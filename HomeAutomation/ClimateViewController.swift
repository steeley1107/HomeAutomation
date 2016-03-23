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
        nodeManager.nodeType(node)
        
        currentHumidityLabel.text = node.thermostatHumidity
        currentTempLabel.text = node.thermostatPV
        setpointTempLabel.text = node.thermostatHeatSP
        
        
        print("\(node.thermostatCoolSP)")
        print("\(node.thermostatHeatSP)")
        print("\(node.thermostatMode)")
        print("\(node.thermostatHumidity)")
        print("\(node.thermostatPV)")

        
        
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
       nodeManager.temperatureUpCommand(node) { (success) -> () in
        
        } 
    }
    
    
    
    @IBAction func downTempButton(sender: AnyObject)
    {
        nodeManager.temperatureDownCommand(node) { (success) -> () in
            
        }

    }
    
    
    
    

}
