//
//  NodeRealm.swift
//  HomeAutomation
//
//  Created by Steele on 2016-06-10.
//  Copyright © 2016 11thHourIndustries. All rights reserved.
//

import RealmSwift

class NodeRealm: Object {
    
// Specify properties to ignore (Realm won't persist these)
    
//  override static func ignoredProperties() -> [String] {
//    return []
//  }
    
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
    
     // dynamic var subnodeArray = [Node]()
    
    //Thermostat features
      dynamic var thermostatPV: String = ""
     dynamic  var thermostatMode: String = ""
     dynamic  var thermostatCoolSP: String = ""
      dynamic var thermostatHeatSP: String = ""
     dynamic  var thermostatHumidity: String = ""
    
   //dynamic var deviceCat:DeviceCat = DeviceCat.x16

    override static func primaryKey() -> String? {
        return "address"
    }
    
}
