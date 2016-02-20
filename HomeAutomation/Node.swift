//
//  Node.swift
//  HomeAutomation
//
//  Created by Steele on 2016-02-19.
//  Copyright © 2016 Steele. All rights reserved.
//

import UIKit

class Node: NSObject {
    
    
//    <node flag="0">
//    <address>27 84 34 4</address>
//    <name>PantryDoor</name>
//    <parent type="1">27 84 34 1</parent>
//    <type>16.2.64.0</type>
//    <enabled>true</enabled>
//    <deviceClass>0</deviceClass>
//    <wattage>0</wattage>
//    <dcPeriod>0</dcPeriod>
//    <pnode>27 84 34 1</pnode>
//    <ELK_ID>F07</ELK_ID>
//    <property id="ST" value=" " formatted=" " uom="on/off"/>
//    </node>
    
    var address: NSNumber = 0.0
    var name: String = ""
    var type: NSNumber = 0.0
    var enabled =  true
    var deviceClass: Int = 0
    var wattage: Int = 0

    


}
