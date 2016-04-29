//
//  ProgramControlTableViewController.swift
//  HomeAutomation
//
//  Created by Steele on 2016-04-29.
//  Copyright © 2016 11thHourIndustries. All rights reserved.
//

import UIKit

class ProgramControlTableViewController: UITableViewController {
    
    
    //Mark: - Properties
    
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var enabledLabel: UILabel!
    @IBOutlet weak var runAtStartupLabel: UILabel!
    @IBOutlet weak var lastRunLabel: UILabel!
    @IBOutlet weak var lastFinishLabel: UILabel!
    @IBOutlet weak var nextRunLabel: UILabel!
    
    var program = Program()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("program \(program.name)")
        
        statusLabel.text = program.status
        enabledLabel.text = program.enabled
        runAtStartupLabel.text = program.runAtStartup
        lastRunLabel.text = program.lastRunTime
        lastFinishLabel.text = program.lastFinishTime
        nextRunLabel.text = program.lastRunTime
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
}
