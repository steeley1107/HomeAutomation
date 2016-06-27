//
//  NodeRealm.swift
//  HomeAutomation
//
//  Created by Steele on 2016-06-10.
//  Copyright © 2016 11thHourIndustries. All rights reserved.
//

import RealmSwift



class FolderRealm: Object {
    
    dynamic var name = ""
    dynamic var address = ""
    dynamic var parent = ""
    dynamic var containsScene = false
    dynamic var containsNode = false
    
    override static func primaryKey() -> String? {
        return "address"
    }
    
}


class SceneRealm: Object {
    
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
