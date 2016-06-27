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
                let node = Node()
                
                //Get the name of the node
                if let name = elem["name"].element?.text!
                {
                    node.name = name
                }
                
                //Get the current folder the node
                if let parent = elem["parent"].element?.text!
                {
                    node.parent = parent
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
                
                //Get the address of the node
                if let address = elem["address"].element?.text!
                {
                    node.address = address
                }
                
                //Get the flag of the node
                if let flag = elem.element?.attributes["flag"]
                {
                    node.flag = flag
                }
                
                //Get the address of the node
                if let type = elem["type"].element?.text!
                {
                    node.type = type
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
                //additional items that are not in the xml file
                
                //Check to see if the node is a dashboard item
                let predicate = NSPredicate(format: "address = %@", node.address)
                let nodeRealmDashboard = realm.objects(Node.self).filter(predicate)
                if nodeRealmDashboard.count != 0
                {
                    node.dashboardItem = nodeRealmDashboard[0].dashboardItem
                }
                
                self.iconSelect(node)
                node.hasChildren = self.subCheck(node)
                
                //Save nodes to Realm
                try! realm.write({
                    realm.add(node, update: true)
                })
            }
            completionHandler(success: true)
        })
    }
    
    
    //create all folders and place them in an array
    func getFolders(completionHandler: (success: Bool) -> ())
    {
        let realm = try! Realm()
        
        let baseURL = NSURL(string: baseURLString + "nodes")
        requestData(NSMutableURLRequest(URL: baseURL!), completionHandler: { (response: XMLIndexer) -> () in
          
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
            
            completionHandler(success: true)
        })
    }
    
    
    //Loads the display array
    func loadArrayRealm(address: String) ->([Any])
    {
        displayArray = []
        let realm = try! Realm()
        
        // Query for all subfolders
        var predicate = NSPredicate(format: "parent = %@", address)
        let folders = realm.objects(FolderRealm.self).filter(predicate)
        
        for folder in folders
        {
            displayArray.append(folder)
        }
        
        // Query all nodes using
        predicate = NSPredicate(format: "parent = %@", address)
        let nodes = realm.objects(Node.self).filter(predicate)
        
        for node in nodes
        {
            displayArray.append(node)
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
        let realm = try! Realm()
        //Create url to get the status of a node
        var commandURLString = baseURLString + "status/" + node.address
        commandURLString = commandURLString.stringByAddingPercentEncodingWithAllowedCharacters( NSCharacterSet.URLQueryAllowedCharacterSet())!
        let commandURL = NSURL(string: commandURLString)
        
        requestData(NSMutableURLRequest(URL: commandURL!), completionHandler: { (response: XMLIndexer) -> () in
            
            //get information of a simple device  on/off
            if let status = response["properties"]["property"].element?.attributes["formatted"], let value = response["properties"]["property"].element?.attributes["value"]
            {
                try! realm.write {
                    node.status = status
                    node.value = value
                    completionHandler(success: true)
                }
            }
            
            //Get information from thermostat
            do
            {
                let thermostatPV = try response["properties"]["property"].withAttr("id", "ST").element?.attributes["formatted"]
                let thermostatMode = try response["properties"]["property"].withAttr("id", "CLIMD").element?.attributes["formatted"]
                let thermostatCoolSP = try response["properties"]["property"].withAttr("id", "CLISPC").element?.attributes["formatted"]
                let thermostatHeatSP = try response["properties"]["property"].withAttr("id", "CLISPH").element?.attributes["formatted"]
                let thermostatHumidity = try response["properties"]["property"].withAttr("id", "CLIHUM").element?.attributes["formatted"]
                
                try! realm.write {
                    node.thermostatPV = String(thermostatPV!.characters.dropLast(3))
                    node.thermostatMode = thermostatMode!
                    node.thermostatCoolSP = String(thermostatCoolSP!.characters.dropLast(3))
                    node.thermostatHeatSP = String(thermostatHeatSP!.characters.dropLast(3))
                    node.thermostatHumidity = String(thermostatHumidity!.characters.dropLast(3))
                }
                completionHandler(success: true)
            }
            catch
            {
            }
        })
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
                let node = Node()
                
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
                let nodeRealm = realm.objects(Node.self).filter(predicate)
                
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
//    func nodeType(node: Node)
//    {
//        //let nodeType = node.type
//        let nodeTypeArray = node.type.componentsSeparatedByString(".")
//        
//        if nodeTypeArray.count > 3 {
//            let deviceCategory: String = nodeTypeArray[0]
//            let subCategory: String = nodeTypeArray[1]
//            let productKey: String = nodeTypeArray[2]
//            node.deviceCat = DeviceCat(rawValue: Int(deviceCategory)!)!
//        }
//        
//    }
    
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
        //let nodeType = node.type
        let nodeTypeArray = node.type.componentsSeparatedByString(".")
        
        if nodeTypeArray.count > 1 {
            let deviceCategory: String = nodeTypeArray[0]
            
            node.deviceCat = Int(deviceCategory)!
        }
        
        switch node.deviceCat {
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
    
    
    //Need to add perameters to allow for queries of different types
    func queryNodesFromRealm() -> [Any]
    {
        let realm = try! Realm()
        
        // Query using an NSPredicate
        let predicate = NSPredicate(format: "dashboardItem = %@", true)
        let elements = realm.objects(Node.self).filter(predicate)
        
        var nodes = [Any]()
        for elem in elements
        {
            nodes.append(elem)
        }
        return nodes
    }
    
    func subCheck(node: Node) -> Bool
    {
        let realm = try! Realm()
        //Check to see if the node is a dashboard item
        let predicate = NSPredicate(format: "parent = %@", node.address)
        let hasChildrenArray = realm.objects(Node.self).filter(predicate)
        print("has children \(hasChildrenArray)")
        if hasChildrenArray.count != 0
        {
            return true
        }
        else
        {
            return false
        }

    
    }
}
