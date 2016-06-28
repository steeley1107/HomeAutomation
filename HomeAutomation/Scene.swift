//
//  Scene.swift
//  HomeAutomation
//
//  Created by Steele on 2016-05-06.
//  Copyright © 2016 11thHourIndustries. All rights reserved.
//

import UIKit
import RealmSwift



class Scene: Object {
    
    
    //    <group flag="132">
    //    <address>22625</address>
    //    <name>WoodStoveFan</name>
    //    <deviceGroup>19</deviceGroup>
    //    <ELK_ID>F03</ELK_ID>
    //    <members>
    //    <link type="32">2E 9B 42 1</link>
    //    </members>
    //    </group>
    
    dynamic var name = ""
    dynamic var address = ""
    dynamic var group = ""
    dynamic var deviceGroup = ""
    dynamic var elkId = ""
    dynamic var link = ""
    dynamic var imageName = ""
    dynamic var enabled = ""
    dynamic var parent = ""
    dynamic var dashboardItem: Bool = false
    
    var members = List<Node>()
    
    override static func primaryKey() -> String? {
        return "address"
    }

    
    
}
