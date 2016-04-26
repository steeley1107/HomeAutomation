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
    var rootfolder = ProgramFolder()
    
    var array = [Any]()
    var displayArray = [Any]()
    
    
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
                
                //Get the status of the node
                if let folder = elem.element?.attributes["folder"]
                {
                    program.folder = folder
                }
                
                //Add node to array of nodes
                if program.folder == "false"
                {
                    self.programs += [program]
                }
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
                    let folder = ProgramFolder()
                    
                    //Get the name of the folder
                    if let name = elem["name"].element?.text!
                    {
                        folder.name = name
                    }
                    //Get the address of the folder
                    if let id = elem.element?.attributes["id"]!
                    {
                        folder.id = id
                    }
                    //Get the parent of the folder
                    if let parent = elem.element?.attributes["parentId"]
                    {
                        folder.parent = parent
                    }
                    
                    
                    //determine if the folder is a root or a sub folder.
                    if folder.parent == ""
                    {
                        self.rootfolder = folder
                    }
                    else
                    {
                        self.programFolders += [folder]
                    }
                }
            }
            
            //Add root folders
            for folder in self.programFolders
            {
                if self.rootfolder.id == folder.parent
                {
                    self.rootfolder.subfolderArray.append(folder)
                }
            }
            
            //Add sub folders
            for rootfolder in self.rootfolder.subfolderArray
            {
                for subfolder in self.programFolders
                {
                    if subfolder.parent == rootfolder.id
                    {
                        rootfolder.subfolderArray += [subfolder]
                    }
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
                        //Add programs to root
                        for program in self.programs
                        {
                            if program.parentId == self.rootfolder.id
                            {
                                self.rootfolder.programArray += [program]
                            }
                        }
                        
                        
                        //Add programs to root
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
                        
                        
//                        //add nodes into sub folders
//                        for rootfolder in self.rootfolder.subfolderArray
//                        {
//                            for subfolder in rootfolder.subfolderArray
//                            {
//                                for program in self.programs
//                                {
//                                    if program.parentId == subfolder.id
//                                    {
//                                        subfolder.programArray += [program]
//                                    }
//                                }
//                            }
//                        }
                        
                        
                        
                        for folder in self.rootfolder.subfolderArray
                        {
                            self.array.append(folder)
                        }
                        
                        for node in self.rootfolder.programArray
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
        if let selectedFolder = array[indexPath.row] as? ProgramFolder
        {
            for folder in selectedFolder.subfolderArray
            {
                displayArray.append(folder)
            }
            for node in selectedFolder.programArray
            {
                displayArray.append(node)
            }
        }
        
//        //Check to see if the cell is a program
//        if let selectedProgram = array[indexPath.row] as? Program
//        {
//            for program in selectedProgram
//            {
//                displayArray.append(node)
//            }
//            
//            //add main node to the list and remove subnodes so it can be selected
//            let rootNode = selectedNode.copy() as! Node
//            rootNode.subnodeArray.removeAll()
//            displayArray.append(rootNode)
//        }
        
        return displayArray
    }
    
    
    
    
    
    
    
    
}
