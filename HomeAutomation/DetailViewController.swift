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
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Init node controller
        self.nodeManager = NodeManager()
        
        nameLabel.text = node.name
        addressLabel.text = node.address
        statusLabel.text = node.status
        
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
                self.statusLabel.text = self.node.status
            }
        }
    }
    
    
    @IBAction func offButton(sender: AnyObject)
    {
        nodeManager.offCommand(node) { (success) -> () in
            if success
            {
                self.statusLabel.text = self.node.status
            }
        }
    }
    
    
}




