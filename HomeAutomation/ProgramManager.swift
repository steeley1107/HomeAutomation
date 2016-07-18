//
//  ProgramManager.swift
//  HomeAutomation
//
//  Created by Steele on 2016-04-04.
//  Copyright © 2016 11thHourIndustries. All rights reserved.
//

import UIKit
import SWXMLHash
import RealmSwift

class ProgramManager: NSObject, NSURLSessionDelegate {
    static let sharedInstance = ProgramManager()
    
    
    //Mark: Properties
    
    var baseURLString = ""
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
        let realm = try! Realm()
        let baseURL = NSURL(string: baseURLString + "programs?subfolders=true")
        requestData(NSMutableURLRequest(URL: baseURL!), completionHandler: { (response: XMLIndexer) -> () in

            for elem in response["programs"]["program"] {
                let program = Program()
                
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
                //Get the enabled option of the program
                if let enabled = elem.element?.attributes["enabled"]
                {
                    program.enabled = enabled
                }
                //Get the run at startup option of the program
                if let runAtStartup = elem.element?.attributes["runAtStartup"]
                {
                    program.runAtStartup = runAtStartup
                }
                //Get the id of the program
                if let id = elem.element?.attributes["id"]
                {
                    program.id = id
                }
                //Get the status of the program
                if let parentId = elem.element?.attributes["parentId"]
                {
                    program.parentId = parentId
                }
                //Get the folder of the program
                if let folder = elem.element?.attributes["folder"]
                {
                    program.folder = folder
                }
                //Get the status of the program
                if let lastRunTime = elem["lastRunTime"].element?.text
                {
                    program.lastRunTime = lastRunTime
                }
                //Get the status of the program
                if let lastFinishTime = elem["lastFinishTime"].element?.text
                {
                    program.lastFinishTime = lastFinishTime
                }
                //Get the status of the program
                if let nextScheduledRunTime = elem["nextScheduledRunTime"].element?.text
                {
                    program.nextScheduledRunTime = nextScheduledRunTime
                }
                
                //Save nodes to Realm
                if program.folder == "false"
                {
                    try! realm.write({
                        realm.add(program, update: true)
                    })
                }
            }
            completionHandler(success: true)
        })
    }
    
    
    //create all folders and place them in an array
    func getProgramFolders(completionHandler: (success: Bool) -> ())
    {
        let realm = try! Realm()
        
        let baseURL = NSURL(string: baseURLString + "programs?subfolders=true")
        requestData(NSMutableURLRequest(URL: baseURL!), completionHandler: { (response: XMLIndexer) -> () in
            
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
                    
                    //Save nodes to Realm
                    try! realm.write({
                        realm.add(folder, update: true)
                    })
                }
            }
            completionHandler(success: true)
        })
    }
    
    
    //Loads the display array
    func loadArray(address: String) ->([Any])
    {
        displayArray = []
        let realm = try! Realm()
        
        // Query for all subfolders
        var predicate = NSPredicate(format: "parent = %@", address)
        let folders = realm.objects(ProgramFolder.self).filter(predicate)
        
        for folder in folders
        {
            displayArray.append(folder)
        }
        
        // Query all nodes using
        predicate = NSPredicate(format: "parentId = %@", address)
        let programs = realm.objects(Program.self).filter(predicate)
        
        for program in programs
        {
            displayArray.append(program)
        }
        
        return displayArray
    }
    
    
    //runs the if portion of the program.
    func programCommand(program: Program, command: String, completionHandler: (success: Bool) -> ())
    {
        ///rest/programs/0032/run|runThen|runElse|stop|enable|disable|enableRunAtStartup|disableRunAtStartup
        
        //Create url for on command
        var commandURLString = baseURLString + "programs/" + program.id + "/" + command
        commandURLString = commandURLString.stringByAddingPercentEncodingWithAllowedCharacters( NSCharacterSet.URLQueryAllowedCharacterSet())!
        
        print("\(commandURLString)")
        let commandURL = NSURL(string: commandURLString)
        
        requestData(NSMutableURLRequest(URL: commandURL!), completionHandler: { (response: XMLIndexer) -> () in
            
            if let status = response["RestResponse"].element?.attributes["succeeded"]
            {
                if status == "true"
                {
                    completionHandler(success: true)
                }
            }
        })
    }
    
    
    //grab data from xml and place programs in a custom class
    func getProgram(program: Program, completionHandler: (success: Bool, program: Program) -> ())
    {
        let baseURL = NSURL(string: baseURLString + "programs/" + program.id)
        requestData(NSMutableURLRequest(URL: baseURL!), completionHandler: { (response: XMLIndexer) -> () in
            
            print("\(baseURL)")
            
            for elem in response["programs"]["program"] {
                let program = Program()
                
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
                //Get the enabled option of the program
                if let enabled = elem.element?.attributes["enabled"]
                {
                    program.enabled = enabled
                }
                //Get the run at startup option of the program
                if let runAtStartup = elem.element?.attributes["runAtStartup"]
                {
                    program.runAtStartup = runAtStartup
                }
                //Get the id of the program
                if let id = elem.element?.attributes["id"]
                {
                    program.id = id
                }
                //Get the status of the program
                if let parentId = elem.element?.attributes["parentId"]
                {
                    program.parentId = parentId
                }
                //Get the folder of the program
                if let folder = elem.element?.attributes["folder"]
                {
                    program.folder = folder
                }
                //Get the status of the program
                if let lastRunTime = elem["lastRunTime"].element?.text
                {
                    program.lastRunTime = lastRunTime
                }
                //Get the status of the program
                if let lastFinishTime = elem["lastFinishTime"].element?.text
                {
                    program.lastFinishTime = lastFinishTime
                }
                
                //Get the status of the program
                if let nextScheduledRunTime = elem["nextScheduledRunTime"].element?.text
                {
                    program.nextScheduledRunTime = nextScheduledRunTime
                }
            }
            completionHandler(success: true, program: program)
        })
    }
    
    
    //Need to add perameters to allow for queries of different types
    func queryNodesFromRealm() -> [Any]
    {
        let realm = try! Realm()
        
        // Query using an NSPredicate
        let predicate = NSPredicate(format: "dashboardItem = %@", true)
        let elements = realm.objects(Program.self).filter(predicate)
        
        var programs = [Any]()
        for elem in elements
        {
            programs.append(elem)
        }
        return programs
    }
    
    
}
