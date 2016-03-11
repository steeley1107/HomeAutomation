//
//  NodeManager.swift
//  HomeAutomation
//
//  Created by Steele on 2016-03-05.
//  Copyright © 2016 Steele. All rights reserved.
//

import UIKit
import SWXMLHash

class NodeManager: NSObject, NSURLSessionDelegate {
    
    //Mark: Properties
    
    //var node = Node()
    var nodes = [Node]()
    var folders = [Folder]()
    var xml: XMLIndexer?
    let baseURL = NSURL(string: "https://admin:paintball1@69.165.175.141/rest/nodes")
    let baseURLString = "https://admin:paintball1@69.165.175.141/rest/"
    
    
    
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
                
                //Get the address of the node
                if let address = elem["address"].element?.text!
                {
                    node.address = address
                }
                
                //Add node to array of nodes
                self.nodes += [node]
            }
            completionHandler(success: true)
        })
    }
    
    
    //create all folders and place them in an array
    func createFolders(completionHandler: (success: Bool) -> ())
    {
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
    func onCommand(node: Node, completionHandler: (success: Bool) -> ())
    {
        ///rest/nodes/<node>/cmd/DFON
        
        //Create url for on command
        var commandURLString = baseURLString + "nodes/" + node.address + "/cmd/DFON"
        commandURLString = commandURLString.stringByAddingPercentEncodingWithAllowedCharacters( NSCharacterSet.URLQueryAllowedCharacterSet())!
        let commandURL = NSURL(string: commandURLString)
        
        //print("url \(commandURL)")
        
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
            if let status = response["properties"]["property"].element?.attributes["formatted"]
            {
                node.status = status
                completionHandler(success: true)
            }
        })
    }
    
    
    
}
