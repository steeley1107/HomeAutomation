//
//  SettingsTableViewController.swift
//  HomeAutomation
//
//  Created by Steele on 2016-03-14.
//  Copyright © 2016 11thHourIndustries. All rights reserved.
//

import UIKit

class SettingsTableViewController: UITableViewController {
    
    //Mark: - Properties
    
    @IBOutlet weak var userNameLabel: UITextField!
    @IBOutlet weak var passwordLabel: UITextField!
    @IBOutlet weak var localIPLabel: UITextField!
    @IBOutlet weak var localPortLabel: UITextField!
    @IBOutlet weak var secureIPLabel: UITextField!
    @IBOutlet weak var securePortLabel: UITextField!
    var nodeManager: NodeManager!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        //Init node controller
        self.nodeManager = NodeManager()
        
        userNameLabel.text = NSUserDefaults.standardUserDefaults().objectForKey("userName") as? String
        passwordLabel.text = NSUserDefaults.standardUserDefaults().objectForKey("password") as? String
        localIPLabel.text = NSUserDefaults.standardUserDefaults().objectForKey("localIP") as? String
        localPortLabel.text = NSUserDefaults.standardUserDefaults().objectForKey("localPort") as? String
        secureIPLabel.text = NSUserDefaults.standardUserDefaults().objectForKey("secureIP") as? String
        securePortLabel.text = NSUserDefaults.standardUserDefaults().objectForKey("securePort") as? String
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func saveButton(sender: AnyObject)
    {
        //Save user defults
        NSUserDefaults.standardUserDefaults().setObject(userNameLabel.text, forKey: "userName")
        NSUserDefaults.standardUserDefaults().setObject(passwordLabel.text, forKey: "password")
        NSUserDefaults.standardUserDefaults().setObject(localIPLabel.text, forKey: "localIP")
        NSUserDefaults.standardUserDefaults().setObject(localPortLabel.text, forKey: "localPort")
        NSUserDefaults.standardUserDefaults().setObject(secureIPLabel.text, forKey: "secureIP")
        NSUserDefaults.standardUserDefaults().setObject(securePortLabel.text, forKey: "securePort")
        
        //create url from user defaults
        var baseString = "https://"
        baseString += userNameLabel.text! + ":" + passwordLabel.text! + "@" + secureIPLabel.text!
        baseString += "/rest/"
        //Save to user defaults
        NSUserDefaults.standardUserDefaults().setObject(baseString, forKey: "baseURLString")
        
        self.view.endEditing(true)
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

    
}
