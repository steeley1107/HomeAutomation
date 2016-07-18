//
//  Folders.swift
//  HomeAutomation
//
//  Created by Steele on 2016-02-23.
//  Copyright © 2016 Steele. All rights reserved.
//

import UIKit
import RealmSwift

class Folder: Object {
    
    dynamic var name = ""
    dynamic var address = ""
    dynamic var parent = ""
    dynamic var containsScene = false
    dynamic var containsNode = false
    
    override static func primaryKey() -> String? {
        return "address"
    }
    
}

