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
    var programManager: ProgramManager!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Init node controller
        self.programManager = ProgramManager()
        
        reload()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        if indexPath.section == 1
        {
            //select which program to run.
            switch indexPath.row {
            case 0:
                programManager.programCommand(program, command: "run", completionHandler: { (success) in
                    if success {
                        print("run")
                        self.reload()
                    }
                })
            case 1:
                programManager.programCommand(program, command: "runThen", completionHandler: { (success) in
                    if success {
                        print("runThen")
                        self.reload()
                    }
                })
            case 2:
                programManager.programCommand(program, command: "runElse", completionHandler: { (success) in
                    if success {
                        print("runElse")
                        self.reload()
                    }
                })
            case 3:
                programManager.programCommand(program, command: "enable", completionHandler: { (success) in
                    if success {
                        print("enable")
                        self.reload()
                    }
                })
            case 4:
                programManager.programCommand(program, command: "disable", completionHandler: { (success) in
                    if success {
                        print("disable")
                        self.reload()
                    }
                })
            case 5:
                programManager.programCommand(program, command: "enableRunAtStartup", completionHandler: { (success) in
                    if success {
                        print("enableRunAtStartup")
                        self.reload()
                    }
                })
            case 6:
                programManager.programCommand(program, command: "disableRunAtStartup", completionHandler: { (success) in
                    if success {
                        print("disableRunAtStartup")
                        self.reload()
                    }
                })
            case 7:
                programManager.programCommand(program, command: "stop", completionHandler: { (success) in
                    if success {
                        print("stop")
                        self.reload()
                    }
                })
            default:
                print("unknown command")
            }
        }
    }
    
    
    func reload()
    {
        programManager.getProgram(self.program) { (success, program) in
            if success == true
            {
                self.statusLabel.text = program.status
                self.enabledLabel.text = program.enabled
                self.runAtStartupLabel.text = program.runAtStartup
                self.lastRunLabel.text = program.lastRunTime
                self.lastFinishLabel.text = program.lastFinishTime
                self.nextRunLabel.text = program.lastRunTime
                print("bla ")
            }
            
        }
        
        
    }
    
}
