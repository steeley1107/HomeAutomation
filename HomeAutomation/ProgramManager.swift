//
//  ProgramManager.swift
//  HomeAutomation
//
//  Created by Steele on 2016-04-04.
//  Copyright © 2016 11thHourIndustries. All rights reserved.
//

import UIKit
import SWXMLHash

class ProgramManager: NSObject, NSURLSessionDelegate {
    
    
    //Mark: Properties
    
    var baseURLString = ""
    var programs = [Program]()
    var programFolders = [ProgramFolder]()
    
    
    //Mark: Program functions
    
    
    
    override init()
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

    
    
    //grab data from xml and place programs in a custom class
    func getPrograms(completionHandler: (success: Bool) -> ())
    {
        let baseURL = NSURL(string: baseURLString + "programs?subfolders=true")
        requestData(NSMutableURLRequest(URL: baseURL!), completionHandler: { (response: XMLIndexer) -> () in
            
            self.programs = []
            for elem in response["programs"]["program"] {
                let program = Program()
                NSLog(elem["name"].element!.text!)
                
                //Get the name of the program
                if let name = elem["name"].element?.text!
                {
                    program.name = name
                }
                
                //Get the status of the program
                if let status = elem.element?.attributes["status"]
                {
                    program.status = status
                }
                
                //Get the id of the program
                if let id = elem.element?.attributes["id"]
                {
                    program.id = id
                }
                
                //Get the status of the node
                if let parentId = elem.element?.attributes["parentId"]
                {
                    program.parentId = parentId
                }
                
                //Add node to array of nodes
                self.programs += [program]
            }
            completionHandler(success: true)
        })
    }
    
    
    //create all folders and place them in an array
    func createProgramFolders(completionHandler: (success: Bool) -> ())
    {
        let baseURL = NSURL(string: baseURLString + "programs?subfolders=true")
        requestData(NSMutableURLRequest(URL: baseURL!), completionHandler: { (response: XMLIndexer) -> () in
            self.programFolders = []
            for elem in response["programs"]["program"]
            {
                let folderStatus = elem.element!.attributes["folder"]
                
                if folderStatus == "true"
                {
                    let name = elem["name"].element!.text!
                    let id = elem.element!.attributes["id"]!
                    
                    let folder = ProgramFolder()
                    folder.name = name
                    folder.id = id
                    self.programFolders += [folder]
                }
            }
            completionHandler(success: true)
        })
    }
    
    //add nodes to the proper folder array
    func addPrograms(completionHandler: (success: Bool) -> ())
    {
        createProgramFolders { (success) -> () in
            if success
            {
                self.getPrograms { (success) -> () in
                    if success
                    {
                        for folder in self.programFolders
                        {
                            for program in self.programs
                            {
                                if program.parentId == folder.id
                                {
                                    folder.programArray += [program]
                                }
                            }
                        }
                    }
                    completionHandler(success: true)
                }
            }
        }
    }
    
    
    
//    //turn on node funtion
//    func onCommand(node: Node, completionHandler: (success: Bool) -> ())
//    {
//        ///rest/nodes/<node>/cmd/DFON
//        
//        //Create url for on command
//        var commandURLString = baseURLString + "nodes/" + node.address + "/cmd/DFON"
//        commandURLString = commandURLString.stringByAddingPercentEncodingWithAllowedCharacters( NSCharacterSet.URLQueryAllowedCharacterSet())!
//        let commandURL = NSURL(string: commandURLString)
//        
//        requestData(NSMutableURLRequest(URL: commandURL!), completionHandler: { (response: XMLIndexer) -> () in
//            
//            if let status = response["RestResponse"].element?.attributes["succeeded"]
//            {
//                if status == "true"
//                {
//                    self.nodeStatus(node, completionHandler: { (success) -> () in
//                        if success
//                        {
//                            completionHandler(success: true)
//                        }
//                    })
//                }
//            }
//        })
//    }

    
    
    
    
    
    
}
