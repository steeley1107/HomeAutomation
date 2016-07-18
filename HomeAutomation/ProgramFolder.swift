//
//  ProgramFolder.swift
//  HomeAutomation
//
//  Created by Steele on 2016-04-04.
//  Copyright © 2016 11thHourIndustries. All rights reserved.
//

import UIKit
import RealmSwift

class ProgramFolder: Object {
    
    dynamic var name = ""
    dynamic var id = ""
    dynamic var parent = ""
    
    override static func primaryKey() -> String? {
        return "id"
    }

}
