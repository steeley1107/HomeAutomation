//
//  Node.swift
//  HomeAutomation
//
//  Created by Steele on 2016-02-19.
//  Copyright © 2016 Steele. All rights reserved.
//

import UIKit
import RealmSwift

class Node: Object {
    
    
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
    
    
    dynamic var address: String = ""
    dynamic var name: String = ""
    dynamic var type: String = ""
    dynamic var enabled: String =  ""
    dynamic var deviceClass: String = ""
    dynamic var wattage: String = ""
    dynamic var status: String = ""
    dynamic var parent: String = ""
    dynamic  var value: String = ""
    dynamic  var imageName: String = ""
    dynamic  var flag: String = ""
    dynamic var dashboardItem: Bool = false
    
    dynamic var deviceCat = 0
    dynamic var hasChildren = false
    
    //Thermostat features
    dynamic var thermostatPV: String = ""
    dynamic  var thermostatMode: String = ""
    dynamic  var thermostatCoolSP: String = ""
    dynamic var thermostatHeatSP: String = ""
    dynamic  var thermostatHumidity: String = ""
    
    override static func primaryKey() -> String? {
        return "address"
    }

}
