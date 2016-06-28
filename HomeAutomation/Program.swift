//
//  Program.swift
//  HomeAutomation
//
//  Created by Steele on 2016-04-04.
//  Copyright © 2016 11thHourIndustries. All rights reserved.
//

import UIKit
import RealmSwift

class Program: Object {
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
    
    
    dynamic var name: String = ""
    dynamic var id: String = ""
    dynamic var parentId: String = ""
    dynamic var status: String = ""
    dynamic var folder: String = ""
    dynamic var imageName: String = ""
    dynamic var lastRunTime: String = ""
    dynamic var lastFinishTime: String = ""
    dynamic var nextScheduledRunTime: String = ""
    dynamic var enabled: String = ""
    dynamic var runAtStartup: String = ""
    dynamic var dashboardItem: Bool = false
    
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    
    
}
