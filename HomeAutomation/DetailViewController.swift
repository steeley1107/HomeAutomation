//
//  ViewController.swift
//  HomeAutomation
//
//  Created by Steele on 2015-12-29.
//  Copyright © 2015 Steele. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController, NSURLSessionDelegate {
    
    
    //Mark: Properties
    var node = Node()
    var nodeManager: NodeManager!
    let gradientLayer = CAGradientLayer()
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var statusIcon: UIImageView!
    @IBOutlet weak var dimSlider: UISlider!
    
    
    //Mark: Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        //
        //        // 1
        //        self.view.backgroundColor = UIColor.init(red: 0.431, green: 0.573, blue: 0.631, alpha: 1) //UIColor.greenColor()
        //
        //        // 2
        //        gradientLayer.frame = self.view.bounds
        //
        //        // 3
        //        let color1 = UIColor(red: 17/255, green: 60/255, blue: 81/255, alpha: 0.9).CGColor as CGColorRef
        //        let color2 = UIColor.init(red: 110/255, green: 146/255, blue: 161/255, alpha: 0.9)
        //        //let color3 = UIColor.clearColor().CGColor as CGColorRef
        //        //let color4 = UIColor(white: 0.0, alpha: 0.7).CGColor as CGColorRef
        //        gradientLayer.colors = [color1, color2]
        //
        //        // 4
        //        gradientLayer.locations = [0.0, 0.80]
        //
        //        // 5
        //        self.view.layer.addSublayer(gradientLayer)
        
        
        //Init node controller
        self.nodeManager = NodeManager()
        
        if let baseURLString = NSUserDefaults.standardUserDefaults().objectForKey("baseURLString") as? String
        {
            nodeManager.baseURLString = baseURLString
        }
        
        nameLabel.text = node.name
        addressLabel.text = node.address
        
        updateView()
        
        dimSlider.continuous = false
        
        nodeManager.nodeType(node)
        
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func onButton(sender: AnyObject)
    {
        
        nodeManager.onCommand(node) { (success) -> () in
            if success
            {
                self.updateView()
            }
        }
    }
    
    
    @IBAction func offButton(sender: AnyObject)
    {
        nodeManager.offCommand(node) { (success) -> () in
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
        
    }
    
    
}




