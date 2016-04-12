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
    
    var address: String = ""
    var name: String = ""
    var type: String = ""
    var enabled: String =  ""
    var deviceClass: String = ""
    var wattage: String = ""
    var status: String = ""
    var parent: String = ""
    var value: String = ""
    var imageName: String = ""
    var flag: String = ""
    
    var subnodeArray = [Node]()
    
    //Thermostat features
    var thermostatPV: String = ""
    var thermostatMode: String = ""
    var thermostatCoolSP: String = ""
    var thermostatHeatSP: String = ""
    var thermostatHumidity: String = ""
    
    var deviceCat:DeviceCat


    override init()
    {
        deviceCat = DeviceCat.x16

    }


}
