//
//  Scene.swift
//  HomeAutomation
//
//  Created by Steele on 2016-05-06.
//  Copyright © 2016 11thHourIndustries. All rights reserved.
//

import UIKit

class Scene: NSObject {
    
    
//    <group flag="132">
//    <address>22625</address>
//    <name>WoodStoveFan</name>
//    <deviceGroup>19</deviceGroup>
//    <ELK_ID>F03</ELK_ID>
//    <members>
//    <link type="32">2E 9B 42 1</link>
//    </members>
//    </group>
    
    var name = ""
    var address = ""
    var group = ""
    var deviceGroup = ""
    var elkId = ""
    var link = ""
    var members = [String]()
    var imageName = ""
    var enabled = ""
    var parent = ""
    
    
}
