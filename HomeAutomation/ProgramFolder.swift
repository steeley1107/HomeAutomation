//
//  ProgramFolder.swift
//  HomeAutomation
//
//  Created by Steele on 2016-04-04.
//  Copyright © 2016 11thHourIndustries. All rights reserved.
//

import UIKit

class ProgramFolder: NSObject {
    
    var name = ""
    var id = ""
    var parent = ""
    var programArray = [Program]()
    
    var subfolderArray = [ProgramFolder]()
    var array = [Any]()
    
    
}
