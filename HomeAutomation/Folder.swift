//
//  Folders.swift
//  HomeAutomation
//
//  Created by Steele on 2016-02-23.
//  Copyright © 2016 Steele. All rights reserved.
//

import UIKit

class Folder: NSObject {
    
    var name = ""
    var address = ""
    var parent = ""
    var nodeArray = [Node]()
    var sceneArray = [Scene]()
    var subfolderArray = [Folder]()
    var array = [Any]()
    var containsScene = false
    var containsNode = false
    
}
