//
//  NodeManager.swift
//  HomeAutomation
//
//  Created by Steele on 2016-03-05.
//  Copyright © 2016 Steele. All rights reserved.
//

import UIKit
import SWXMLHash

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
    
    //Mark: Properties
    
    var nodes = [Node]()
    var folders = [Folder]()
    var xml: XMLIndexer?
    var baseURLString = ""
    
    
    //Mark: Functions
    
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
    
    
    //grab data from xml and place nodes in a custom class
    func getNodes(completionHandler: (success: Bool) -> ())
    {
        
        let baseURL = NSURL(string: baseURLString + "nodes")
        requestData(NSMutableURLRequest(URL: baseURL!), completionHandler: { (response: XMLIndexer) -> () in
            
            self.nodes = []
            for elem in response["nodes"]["node"] {
                let node = Node()
                NSLog(elem["name"].element!.text!)
                
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
                
                //Get the address of the node
                if let type = elem["type"].element?.text!
                {
                    node.type = type
                    self.nodeType(node)
                }
                
                
                //Get information from thermostat
                do
                {
                    let thermostatPV = try elem["property"].withAttr("id", "ST").element?.attributes["formatted"]
                    let thermostatMode = try elem["property"].withAttr("id", "CLIMD").element?.attributes["formatted"]
                    let thermostatCoolSP = try elem["property"].withAttr("id", "CLISPC").element?.attributes["formatted"]
                    let thermostatHeatSP = try elem["property"].withAttr("id", "CLISPH").element?.attributes["formatted"]
                    let thermostatHumidity = try elem["property"].withAttr("id", "CLIHUM").element?.attributes["formatted"]
                    
                    node.thermostatPV = thermostatPV!
                    node.thermostatMode = thermostatMode!
                    node.thermostatCoolSP = thermostatCoolSP!
                    node.thermostatHeatSP = thermostatHeatSP!
                    node.thermostatHumidity = thermostatHumidity!
                }
                catch
                {
                }
                
                
                
                
                //
                //                <node flag="128">
                //                <address>1F 17 C9 1</address>
                //                <name>ShopHeat</name>
                //                <parent type="3">57742</parent>
                //                <type>5.11.13.243</type>
                //                <enabled>true</enabled>
                //                <deviceClass>1</deviceClass>
                //                <wattage>1000</wattage>
                //                <dcPeriod>60</dcPeriod>
                //                <pnode>1F 17 C9 1</pnode>
                //                <ELK_ID>C15</ELK_ID>
                //                <property id="ST" value="100" formatted="50.00" uom="degrees"/>
                //                <property id="CLIMD" value="1" formatted="Heat" uom="n/a"/>
                //                <property id="CLISPC" value="158" formatted="79.00" uom="degrees"/>
                //                <property id="CLISPH" value="78" formatted="39.00" uom="degrees"/>
                //                <property id="CLIHUM" value="44" formatted="44.00" uom="%"/>
                //                </node>
                //
                
                
                
                
                
                
                
                
                
                
                
                
                //Add node to array of nodes
                self.nodes += [node]
            }
            completionHandler(success: true)
        })
    }
    
    
    //create all folders and place them in an array
    func createFolders(completionHandler: (success: Bool) -> ())
    {
        let baseURL = NSURL(string: baseURLString + "nodes")
        requestData(NSMutableURLRequest(URL: baseURL!), completionHandler: { (response: XMLIndexer) -> () in
            self.folders = []
            for elem in response["nodes"]["folder"]
            {
                let name = elem["name"].element!.text!
                let address = elem["address"].element!.text!
                let folder = Folder()
                folder.name = name
                folder.address = address
                self.folders += [folder]
            }
            let folder = Folder()
            folder.name = "Other"
            self.folders += [folder]
            completionHandler(success: true)
        })
    }
    
    
    
    //add nodes to the proper folder array
    func addNodes(completionHandler: (success: Bool) -> ())
    {
        
        createFolders { (success) -> () in
            if success
            {
                self.getNodes { (success) -> () in
                    if success
                    {
                        for folder in self.folders
                        {
                            print("folders \(folder.name)")
                            for node in self.nodes
                            {
                                if node.parent == folder.address
                                {
                                    print("node \(node.name)")
                                    folder.nodeArray += [node]
                                }
                            }
                        }
                    }
                    completionHandler(success: true)
                }
            }
        }
        
    }
    
    
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
    
    
    //turn on node funtion
    func onCommand(node: Node, completionHandler: (success: Bool) -> ())
    {
        ///rest/nodes/<node>/cmd/DFON
        
        //Create url for on command
        var commandURLString = baseURLString + "nodes/" + node.address + "/cmd/DFON"
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
    
    //turn off node function
    func offCommand(node: Node, completionHandler: (success: Bool) -> ())
    {
        ///rest/nodes/<node>/cmd/DFOF
        
        //Create url for off command
        var commandURLString = baseURLString + "nodes/" + node.address + "/cmd/DFOF"
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
    
    
    //get the status of a node
    func nodeStatus(node: Node, completionHandler: (success: Bool) -> ())
    {
        ///rest/status/<node>
        
        //Create url to get the status of a node
        var commandURLString = baseURLString + "status/" + node.address
        commandURLString = commandURLString.stringByAddingPercentEncodingWithAllowedCharacters( NSCharacterSet.URLQueryAllowedCharacterSet())!
        let commandURL = NSURL(string: commandURLString)
        
        requestData(NSMutableURLRequest(URL: commandURL!), completionHandler: { (response: XMLIndexer) -> () in
            if let status = response["properties"]["property"].element?.attributes["formatted"], let value = response["properties"]["property"].element?.attributes["value"]
            {
                node.status = status
                node.value = value
                completionHandler(success: true)
            }
        })
    }
    
    
    func nodeType(node: Node)
    {
        
        let nodeType = node.type
        let nodeTypeArray = nodeType.componentsSeparatedByString(".")
        
        let deviceCategory: String = nodeTypeArray[0]
        let subCategory: String = nodeTypeArray[1]
        let productKey: String = nodeTypeArray[2]
        
        node.deviceCat = DeviceCat(rawValue: Int(deviceCategory)!)!
        
        
    }
    
    
}
