//
//  Program.swift
//  HomeAutomation
//
//  Created by Steele on 2016-04-04.
//  Copyright © 2016 11thHourIndustries. All rights reserved.
//

import UIKit

class Program: NSObject {
    //      folder
    //    <program id="0022" parentId="0001" status="true" folder="true">
    //    <name>Email</name>
    //    <lastRunTime/>
    //    <lastFinishTime/>
    //    </program>
    
    //    program
    //    <program id="0028" parentId="0007" status="false" folder="false" enabled="true" runAtStartup="false" running="idle">
    //    <name>SinkLightNight</name>
    //    <lastRunTime>2016/04/04 3:08:18 PM</lastRunTime>
    //    <lastFinishTime>2016/04/04 3:08:18 PM</lastFinishTime>
    //    <nextScheduledRunTime>2016/04/05 12:00:00 AM</nextScheduledRunTime>
    //    </program>
    
    
    var name: String = ""
    var id: String = ""
    var parentId: String = ""
    var status: String = ""
    var folder: String = ""
    var imageName: String = ""
    var lastRunTime: String = ""
    var lastFinishTime: String = ""
    var nextScheduledRunTime: String = ""
    var enabled: String = ""
    var runAtStartup: String = ""
    
    
    
    override init() {
        
    }
    
    
    
}
