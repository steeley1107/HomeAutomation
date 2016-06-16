//
//  NodeManager.swift
//  HomeAutomation
//
//  Created by Steele on 2016-03-05.
//  Copyright © 2016 Steele. All rights reserved.
//

import UIKit
import SWXMLHash
import RealmSwift

enum DeviceCat : Int {
    case RemoteLinc = 0     //0x00 Generalized Controllers ControLinc, RemoteLinc, SignaLinc, etc.
    case Dimmable = 1       //0x01 Dimmable Lighting Control Dimmable Light Switches, Dimmable Plug-In Modules
    case Switched = 2       //0x02 Switched Lighting Control Relay Switches, Relay Plug-In Modules
    case Network = 3        //0x03 Network Bridges PowerLinc Controllers, TRex, Lonworks, ZigBee, etc.
    case Irrigation = 4     //0x04 Irrigation Control Irrigation Management, Sprinkler Controllers
    case Climate = 5        //0x05 Climate Control Heating, Air conditioning, Exhausts Fans, Ceiling Fans, Indoor Air Quality
    case PoolAndSpa = 6     //0x06 Pool and Spa Control Pumps, Heaters, Chemicals
    case Sensors = 7        //0x07 Sensors and Actuators Sensors, Contact Closures
    case AV = 8             //0x08 Home Entertainment Audio/Video Equipment
    case Energy = 9         //0x09 Energy Management Electricity, Water, Gas Consumption, Leak Monitors
    case x0A = 10           //0x0A Built-In Appliance Control White Goods, Brown Goods
    case x0B = 11           //0x0B Plumbing Faucets, Showers, Toilets
    case x0C = 12           //0x0C Communication Telephone System Controls, Intercoms
    case x0D = 13           //0x0D Computer Control PC On/Off, UPS Control, App Activation, Remote Mouse, Keyboards
    case x0E = 14           //0x0E Window Coverings Drapes, Blinds, Awnings
    case x0F = 15           //0x0F Access Control Automatic Doors, Gates, Windows, Locks
    case x10 = 16           //0x10 Security, Health, Safety Door and Window Sensors, Motion Sensors, Scales
    case x11 = 17           //0x11 Surveillance Video Camera Control, Time-lapse Recorders, Security System Links
    case x12 = 18           //0x12 Automotive Remote Starters, Car Alarms, Car Door Locks
    case x13 = 19           //0x13 Pet Care Pet Feeders, Trackers
    case x14 = 20           //0x14 Toys Model Trains, Robots
    case x15 = 21           //0x15 Timekeeping Clocks, Alarms, Timers
    case x16 = 22           //0x16 Holiday Christmas Lights, Displays
    
}


class NodeManager: NSObject, NSURLSessionDelegate {
    static let sharedInstance = NodeManager()
    
    
    //Mark: Properties
    
    var array = [Any]()
    var displayArray = [Any]()
    var nodes = [Node]()
    var subnodes = [Node]()
    var rootfolder = Folder()
    var folders = [Folder]()
    var subfolders = [Folder]()
    var xml: XMLIndexer?
    var baseURLString = ""
    
    var programs = [Program]()
    var programFolders = [ProgramFolder]()
    
    
    //Mark: Functions
    
    override private init()
    {
        if let baseURLString = NSUserDefaults.standardUserDefaults().objectForKey("baseURLString") as? String
        {
            self.baseURLString = baseURLString
        }
    }
    
    
    // get information from ISY994
    func requestData(request: NSMutableURLRequest, completionHandler: (response: XMLIndexer) -> ())
    {
        let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
        
        let session = NSURLSession(configuration: configuration, delegate: self, delegateQueue:NSOperationQueue.mainQueue())
        
        let task = session.dataTaskWithRequest(request) {
            
            (data: NSData?, response: NSURLResponse?, error: NSError?) -> Void in
            if error == nil
            {
                completionHandler(response: SWXMLHash.parse(data!))
            }
        }
        task.resume()
    }
    
    
    //Allow server to connect without SSL Certs
    func URLSession(session: NSURLSession, didReceiveChallenge challenge: NSURLAuthenticationChallenge, completionHandler: (NSURLSessionAuthChallengeDisposition, NSURLCredential?) -> Void)
    {
        completionHandler(NSURLSessionAuthChallengeDisposition.UseCredential, NSURLCredential(forTrust: challenge.protectionSpace.serverTrust!))
    }
    
    
    //grab data from xml and place nodes in Rrealm
    func getNodes(completionHandler: (success: Bool) -> ())
    {
        let realm = try! Realm()
        
        let baseURL = NSURL(string: baseURLString + "nodes")
        requestData(NSMutableURLRequest(URL: baseURL!), completionHandler: { (response: XMLIndexer) -> () in
            
            for elem in response["nodes"]["node"] {
                let nodeRealm = NodeRealm()
                
                //Get the name of the node
                if let name = elem["name"].element?.text!
                {
                    nodeRealm.name = name
                }
                
                //Get the current folder the node
                if let parent = elem["parent"].element?.text!
                {
                    nodeRealm.parent = parent
                }
                
                //Get the status of the node
                if let status = elem["property"].element?.attributes["formatted"]
                {
                    nodeRealm.status = status
                }
                
                //Get the status of the node
                if let value = elem["property"].element?.attributes["value"]
                {
                    nodeRealm.value = value
                }
                
                //Get the address of the node
                if let address = elem["address"].element?.text!
                {
                    nodeRealm.address = address
                }
                
                //Get the flag of the node
                if let flag = elem.element?.attributes["flag"]
                {
                    nodeRealm.flag = flag
                }
                
                //Get the address of the node
                if let type = elem["type"].element?.text!
                {
                    nodeRealm.type = type
                }
                
                
                //Get information from thermostat
                do
                {
                    let thermostatPV = try elem["property"].withAttr("id", "ST").element?.attributes["formatted"]
                    let thermostatMode = try elem["property"].withAttr("id", "CLIMD").element?.attributes["formatted"]
                    let thermostatCoolSP = try elem["property"].withAttr("id", "CLISPC").element?.attributes["formatted"]
                    let thermostatHeatSP = try elem["property"].withAttr("id", "CLISPH").element?.attributes["formatted"]
                    let thermostatHumidity = try elem["property"].withAttr("id", "CLIHUM").element?.attributes["formatted"]
                    
                    nodeRealm.thermostatPV = String(thermostatPV!.characters.dropLast(3))
                    nodeRealm.thermostatMode = thermostatMode!
                    nodeRealm.thermostatCoolSP = String(thermostatCoolSP!.characters.dropLast(3))
                    nodeRealm.thermostatHeatSP = String(thermostatHeatSP!.characters.dropLast(3))
                    nodeRealm.thermostatHumidity = String(thermostatHumidity!.characters.dropLast(3))
                    
                }
                catch
                {
                }
                
                //Save nodes to Realm
                try! realm.write({
                    realm.add(nodeRealm, update: true)
                })
            }
            
            self.getNodesFromRealm({ (success) in
                //
            })
            
            completionHandler(success: true)
        })
    }
    
    
    //create all folders and place them in an array
    func createFolders(completionHandler: (success: Bool) -> ())
    {
        let realm = try! Realm()
        
        let baseURL = NSURL(string: baseURLString + "nodes")
        requestData(NSMutableURLRequest(URL: baseURL!), completionHandler: { (response: XMLIndexer) -> () in
            self.rootfolder = Folder()
            for elem in response["nodes"]["folder"]
            {
                let folderRealm = FolderRealm()
                
                //Get the name of the folder
                if let name = elem["name"].element?.text!
                {
                    folderRealm.name = name
                }
                //Get the address of the folder
                if let address = elem["address"].element?.text!
                {
                    folderRealm.address = address
                }
                //Get the parent folder
                if let parent = elem["parent"].element?.text!
                {
                    folderRealm.parent = parent
                }
                
                //Save nodes to Realm
                try! realm.write({
                    realm.add(folderRealm, update: true)
                })
            }
            
            self.createFoldersFromRealm({ (success) in
                
                
            })
            
            completionHandler(success: true)
        })
    }
    
    
    
    //add nodes to the proper folder array
    func addNodes(completionHandler: (success: Bool) -> ())
    {
        createFoldersFromRealm { (success) -> () in
            
            //createFolders { (success) -> () in
            if success
            {
                self.getNodesFromRealm { (success) -> () in
                    //self.getNodes { (success) -> () in
                    if success
                    {
                        //add nodes into sub folders
                        for rootfolder in self.rootfolder.subfolderArray
                        {
                            for subfolder in rootfolder.subfolderArray
                            {
                                for node in self.nodes
                                {
                                    if node.parent == subfolder.address
                                    {
                                        subfolder.nodeArray += [node]
                                        subfolder.containsNode = true
                                        rootfolder.containsNode = true
                                    }
                                }
                            }
                        }
                        
                        //add nodes into root folder
                        for rootfolder in self.rootfolder.subfolderArray
                        {
                            for node in self.nodes
                            {
                                if node.parent == rootfolder.address
                                {
                                    rootfolder.nodeArray += [node]
                                }
                            }
                        }
                        
                        //add subnode into subnodes array
                        for rootnode in self.nodes
                        {
                            for subnode in self.subnodes
                            {
                                if subnode.parent == rootnode.address
                                {
                                    rootnode.subnodeArray += [subnode]
                                }
                            }
                        }
                        
                        //add nodes into root folder
                        for node in self.nodes
                        {
                            if node.parent == ""
                            {
                                self.rootfolder.nodeArray += [node]
                            }
                        }
                        
                        self.array = []
                        for folder in self.rootfolder.subfolderArray
                        {
                            self.array.append(folder)
                        }
                        for node in self.rootfolder.nodeArray
                        {
                            self.array.append(node)
                        }
                    }
                    completionHandler(success: true)
                }
            }
        }
    }
    
    
    
    
    func loadArray(indexPath: NSIndexPath, array: [Any]) ->([Any])
    {
        displayArray = []
        //Check to see if the cell is a folder
        if let selectedFolder = array[indexPath.row] as? Folder
        {
            for folder in selectedFolder.subfolderArray
            {
                displayArray.append(folder)
            }
            for node in selectedFolder.nodeArray
            {
                displayArray.append(node)
            }
        }
        
        //Check to see if the cell is a node
        if let selectedNode = array[indexPath.row] as? Node
        {
            for node in selectedNode.subnodeArray
            {
                displayArray.append(node)
            }
            
            //add main node to the list and remove subnodes so it can be selected
            let rootNode = selectedNode.copy() as! Node
            rootNode.subnodeArray.removeAll()
            displayArray.append(rootNode)
        }
        
        return displayArray
    }
    
    
    //Mark: node commands
    
    
    //turn on node funtion
    func onPercentageCommand(node: Node, percent: Int, completionHandler: (success: Bool) -> ())
    {
        ///rest/nodes/<node>/cmd/DFON/255
        
        //Create url for on command
        var commandURLString = baseURLString + "nodes/" + node.address + "/cmd/DON/" + String(percent)
        commandURLString = commandURLString.stringByAddingPercentEncodingWithAllowedCharacters( NSCharacterSet.URLQueryAllowedCharacterSet())!
        
        print("\(commandURLString)")
        let commandURL = NSURL(string: commandURLString)
        
        requestData(NSMutableURLRequest(URL: commandURL!), completionHandler: { (response: XMLIndexer) -> () in
            
            if let status = response["RestResponse"].element?.attributes["succeeded"]
            {
                if status == "true"
                {
                    self.nodeStatus(node, completionHandler: { (success) -> () in
                        if success
                        {
                            completionHandler(success: true)
                        }
                    })
                }
            }
        })
    }
    
    
    //turn on and off node funtion
    func command(node: Node, command: String, completionHandler: (success: Bool) -> ())
    {
        ///rest/nodes/<node>/cmd/DFON|DFOF
        
        //Create url for on command
        var commandURLString = baseURLString + "nodes/" + node.address + "/cmd/" + command
        commandURLString = commandURLString.stringByAddingPercentEncodingWithAllowedCharacters( NSCharacterSet.URLQueryAllowedCharacterSet())!
        let commandURL = NSURL(string: commandURLString)
        
        
        requestData(NSMutableURLRequest(URL: commandURL!), completionHandler: { (response: XMLIndexer) -> () in
            
            if let status = response["RestResponse"].element?.attributes["succeeded"]
            {
                if status == "true"
                {
                    self.nodeStatus(node, completionHandler: { (success) -> () in
                        if success
                        {
                            completionHandler(success: true)
                        }
                    })
                }
            }
        })
    }
    
    
    //control the temperature
    func temperatureChangeCommand(node: Node, tempSP: Int, completionHandler: (success: Bool) -> ())
    {
        ///rest/nodes/<node>/cmd/CLISPH/heatsetpoint
        
        //temp control SP 1 = 0.5 degrees.
        let currentSP = Float(node.thermostatHeatSP)
        let newTempSP = Int(currentSP!) * 2 + tempSP
        
        //Create url for on command
        var commandURLString = baseURLString + "nodes/" + node.address + "/cmd/CLISPH/" + String(newTempSP)
        commandURLString = commandURLString.stringByAddingPercentEncodingWithAllowedCharacters( NSCharacterSet.URLQueryAllowedCharacterSet())!
        
        print("\(commandURLString)")
        let commandURL = NSURL(string: commandURLString)
        
        requestData(NSMutableURLRequest(URL: commandURL!), completionHandler: { (response: XMLIndexer) -> () in
            
            if let status = response["RestResponse"].element?.attributes["succeeded"]
            {
                if status == "true"
                {
                    self.nodeStatus(node, completionHandler: { (success) -> () in
                        if success
                        {
                            completionHandler(success: true)
                        }
                    })
                }
            }
        })
    }
    
    
    //get the status of a node
    func nodeStatus(node: Node, completionHandler: (success: Bool) -> ())
    {
        ///rest/status/<node>
        
        //Create url to get the status of a node
        var commandURLString = baseURLString + "status/" + node.address
        commandURLString = commandURLString.stringByAddingPercentEncodingWithAllowedCharacters( NSCharacterSet.URLQueryAllowedCharacterSet())!
        let commandURL = NSURL(string: commandURLString)
        
        requestData(NSMutableURLRequest(URL: commandURL!), completionHandler: { (response: XMLIndexer) -> () in
            
            //get information of a simple device  on/off
            if let status = response["properties"]["property"].element?.attributes["formatted"], let value = response["properties"]["property"].element?.attributes["value"]
            {
                node.status = status
                node.value = value
                completionHandler(success: true)
            }
            
            //Get information from thermostat
            do
            {
                let thermostatPV = try response["properties"]["property"].withAttr("id", "ST").element?.attributes["formatted"]
                let thermostatMode = try response["properties"]["property"].withAttr("id", "CLIMD").element?.attributes["formatted"]
                let thermostatCoolSP = try response["properties"]["property"].withAttr("id", "CLISPC").element?.attributes["formatted"]
                let thermostatHeatSP = try response["properties"]["property"].withAttr("id", "CLISPH").element?.attributes["formatted"]
                let thermostatHumidity = try response["properties"]["property"].withAttr("id", "CLIHUM").element?.attributes["formatted"]
                
                node.thermostatPV = String(thermostatPV!.characters.dropLast(3))
                node.thermostatMode = thermostatMode!
                node.thermostatCoolSP = String(thermostatCoolSP!.characters.dropLast(3))
                node.thermostatHeatSP = String(thermostatHeatSP!.characters.dropLast(3))
                node.thermostatHumidity = String(thermostatHumidity!.characters.dropLast(3))
                
                completionHandler(success: true)
            }
            catch
            {
            }
        })
        
        // Creating a book with the same primary key as a previously saved book
        let realm = try! Realm()
        
        //Update nodes in Realm
        let predicate = NSPredicate(format: "address = %@", node.address)
        let nodeRealm = realm.objects(NodeRealm.self).filter(predicate)
        
        try! realm.write {
            nodeRealm.setValue(node.status, forKey: "status")
            nodeRealm.setValue(node.value, forKey: "value")
            
            nodeRealm.setValue(node.thermostatPV, forKey: "thermostatPV")
            nodeRealm.setValue(node.thermostatMode, forKey: "thermostatMode")
            nodeRealm.setValue(node.thermostatCoolSP, forKey: "thermostatCoolSP")
            nodeRealm.setValue(node.thermostatHeatSP, forKey: "thermostatHeatSP")
            nodeRealm.setValue(node.thermostatHumidity, forKey: "thermostatHumidity")
        }
    }
    
    //Get the status of all nodes
    func getStatusAllNodes(completionHandler: (success: Bool) -> ())
    {
        let realm = try! Realm()
        
        //Create url to get the status of a node
        var commandURLString = baseURLString + "status"
        commandURLString = commandURLString.stringByAddingPercentEncodingWithAllowedCharacters( NSCharacterSet.URLQueryAllowedCharacterSet())!
        let commandURL = NSURL(string: commandURLString)
        
        requestData(NSMutableURLRequest(URL: commandURL!), completionHandler: { (response: XMLIndexer) -> () in
            
            for elem in response["nodes"]["node"] {
                let node = NodeRealm()
                
                //Get the current folder the node
                if let address = elem["id"].element?.text!
                {
                    node.address = address
                }
                
                //Get the status of the node
                if let status = elem["property"].element?.attributes["formatted"]
                {
                    node.status = status
                }
                
                //Get the status of the node
                if let value = elem["property"].element?.attributes["value"]
                {
                    node.value = value
                }
                
                //Get information from thermostat
                do
                {
                    let thermostatPV = try elem["property"].withAttr("id", "ST").element?.attributes["formatted"]
                    let thermostatMode = try elem["property"].withAttr("id", "CLIMD").element?.attributes["formatted"]
                    let thermostatCoolSP = try elem["property"].withAttr("id", "CLISPC").element?.attributes["formatted"]
                    let thermostatHeatSP = try elem["property"].withAttr("id", "CLISPH").element?.attributes["formatted"]
                    let thermostatHumidity = try elem["property"].withAttr("id", "CLIHUM").element?.attributes["formatted"]
                    
                    node.thermostatPV = String(thermostatPV!.characters.dropLast(3))
                    node.thermostatMode = thermostatMode!
                    node.thermostatCoolSP = String(thermostatCoolSP!.characters.dropLast(3))
                    node.thermostatHeatSP = String(thermostatHeatSP!.characters.dropLast(3))
                    node.thermostatHumidity = String(thermostatHumidity!.characters.dropLast(3))
                    
                }
                catch
                {
                }
                
                //Update nodes in Realm
                let predicate = NSPredicate(format: "address = %@", node.address)
                let nodeRealm = realm.objects(NodeRealm.self).filter(predicate)
                
                try! realm.write {
                    nodeRealm.setValue(node.status, forKey: "status")
                    nodeRealm.setValue(node.value, forKey: "value")
                    
                    nodeRealm.setValue(node.thermostatPV, forKey: "thermostatPV")
                    nodeRealm.setValue(node.thermostatMode, forKey: "thermostatMode")
                    nodeRealm.setValue(node.thermostatCoolSP, forKey: "thermostatCoolSP")
                    nodeRealm.setValue(node.thermostatHeatSP, forKey: "thermostatHeatSP")
                    nodeRealm.setValue(node.thermostatHumidity, forKey: "thermostatHumidity")
                }
            }
            completionHandler(success: true)
        })
    }
    
    
    //function to determine the type of node, so it can just to the right screen
    //ie. thermostat can go to climate screen.
    func nodeType(node: Node)
    {
        //let nodeType = node.type
        let nodeTypeArray = node.type.componentsSeparatedByString(".")
        
        if nodeTypeArray.count > 3 {
            let deviceCategory: String = nodeTypeArray[0]
            let subCategory: String = nodeTypeArray[1]
            let productKey: String = nodeTypeArray[2]
            node.deviceCat = DeviceCat(rawValue: Int(deviceCategory)!)!
        }
        
    }
    
    //function to call delays in the program.
    func delay(delay:Double, closure:()->()) {
        dispatch_after(
            dispatch_time(
                DISPATCH_TIME_NOW,
                Int64(delay * Double(NSEC_PER_SEC))
            ),
            dispatch_get_main_queue(), closure)
    }
    
    //select icon based on device catagory
    func iconSelect(node: Node)
    {
        switch node.deviceCat.rawValue {
        case 0:
            node.imageName = "remote"
        case 1:
            node.imageName = "light01"
        case 2:
            node.imageName = "deskLamp"
        case 5:
            node.imageName = "temp"
        case 7:
            node.imageName = "motion01"
        case 9:
            node.imageName = "energy"
        case 16:
            node.imageName = "motion01"
        default:
            node.imageName = "lamp01"
        }
        
    }
    
    
    //grab data from realm and place nodes in a custom class
    func getNodesFromRealm(completionHandler: (success: Bool) -> ())
    {
        let realm = try! Realm()
        let elements = realm.objects(NodeRealm.self)
        
        self.nodes = []
        for elem in elements
        {
            let node = Node()
            
            node.name = elem.name
            node.parent = elem.parent
            node.status = elem.status
            node.value = elem.value
            node.address = elem.address
            node.flag = elem.flag
            node.type = elem.type
            node.dashboardItem = elem.dashboardItem
            
            self.nodeType(node)
            self.iconSelect(node)
            
            //Get information from thermostat
            node.thermostatPV = elem.thermostatPV
            node.thermostatMode = elem.thermostatMode
            node.thermostatCoolSP = elem.thermostatCoolSP
            node.thermostatHeatSP = elem.thermostatHeatSP
            node.thermostatHumidity = elem.thermostatHumidity
            
            //Add node to array of nodes
            if node.flag == "0"
            {
                self.subnodes += [node]
            }
            else
            {
                self.nodes += [node]
            }
        }
        completionHandler(success: true)
    }
    
    
    //create all folders and place them in an array
    func createFoldersFromRealm(completionHandler: (success: Bool) -> ())
    {
        let realm = try! Realm()
        let folders = realm.objects(FolderRealm.self)
        
        self.rootfolder = Folder()
        
        for folderRealm in folders
        {
            let folder = Folder()
            
            //Get the name of the folder
            folder.name = folderRealm.name
            folder.address = folderRealm.address
            folder.parent = folderRealm.parent
            
            //determine if the folder is a root or a sub folder.
            if folder.parent == ""
            {
                self.rootfolder.subfolderArray += [folder]
            }
            else
            {
                self.subfolders += [folder]
            }
        }
        
        for rootfolder in self.rootfolder.subfolderArray
        {
            for subfolder in self.subfolders
            {
                if subfolder.parent == rootfolder.address
                {
                    rootfolder.subfolderArray += [subfolder]
                }
            }
        }
        
        completionHandler(success: true)
        
    }
    
    
    //Need to add perameters to allow for queries of different types
    func queryNodesFromRealm() -> [Any]
    {
        let realm = try! Realm()
        
        // Query using an NSPredicate
        let predicate = NSPredicate(format: "dashboardItem = %@", true)
        let elements = realm.objects(NodeRealm.self).filter(predicate)

        var nodes = [Any]()
        for elem in elements
        {
            let node = Node()
            
            node.name = elem.name
            node.parent = elem.parent
            node.status = elem.status
            node.value = elem.value
            node.address = elem.address
            node.flag = elem.flag
            node.type = elem.type
            
            self.nodeType(node)
            self.iconSelect(node)
            
            //Get information from thermostat
            node.thermostatPV = elem.thermostatPV
            node.thermostatMode = elem.thermostatMode
            node.thermostatCoolSP = elem.thermostatCoolSP
            node.thermostatHeatSP = elem.thermostatHeatSP
            node.thermostatHumidity = elem.thermostatHumidity
            
            nodes.append(node)
        }
        return nodes
    }
    
    
}
