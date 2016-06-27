//
//  SceneManager.swift
//  HomeAutomation
//
//  Created by Steele on 2016-05-06.
//  Copyright © 2016 11thHourIndustries. All rights reserved.
//

import UIKit
import SWXMLHash
import RealmSwift

class SceneManager: NSObject, NSURLSessionDelegate {
    
    
    
    //Mark: Properties
    
    var array = [Any]()
    var scenes = [Scene]()
    var displayArray = [Any]()
    var xml: XMLIndexer?
    var baseURLString = ""
    var rootfolder = Folder()
    var subfolders = [Folder]()
    var nodeManager: NodeManager!
    var sceneControl = [String]()
    
    
    
    
    //Mark: Functions
    
    
    override init()
    {
        //Init node controller
        if let baseURLString = NSUserDefaults.standardUserDefaults().objectForKey("baseURLString") as? String
        {
            self.baseURLString = baseURLString
        }
        self.nodeManager = NodeManager.sharedInstance
        
        sceneControl = ["On", "Off"]
        
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
    
//    //create all folders and place them in an array
//    func createFolders(completionHandler: (success: Bool) -> ())
//    {
//        let baseURL = NSURL(string: baseURLString + "nodes")
//        requestData(NSMutableURLRequest(URL: baseURL!), completionHandler: { (response: XMLIndexer) -> () in
//            self.rootfolder = Folder()
//            for elem in response["nodes"]["folder"]
//            {
//                let folder = Folder()
//                
//                //Get the name of the folder
//                if let name = elem["name"].element?.text!
//                {
//                    folder.name = name
//                }
//                //Get the address of the folder
//                if let address = elem["address"].element?.text!
//                {
//                    folder.address = address
//                }
//                //Get the parent folder
//                if let parent = elem["parent"].element?.text!
//                {
//                    folder.parent = parent
//                }
//                //determine if the folder is a root or a sub folder.
//                if folder.parent == ""
//                {
//                    self.rootfolder.subfolderArray += [folder]
//                }
//                else
//                {
//                    self.subfolders += [folder]
//                }
//            }
//            
//            for rootfolder in self.rootfolder.subfolderArray
//            {
//                for subfolder in self.subfolders
//                {
//                    if subfolder.parent == rootfolder.address
//                    {
//                        rootfolder.subfolderArray += [subfolder]
//                    }
//                }
//            }
//            
//            
//            
//            
//            
//            
//            
//            completionHandler(success: true)
//        })
//    }
    
    
    //grab data from xml and place scenes in a scene array
    func getScenes(completionHandler: (success: Bool) -> ())
    {
        let realm = try! Realm()
        
        let baseURL = NSURL(string: baseURLString + "nodes/scenes")
        requestData(NSMutableURLRequest(URL: baseURL!), completionHandler: { (response: XMLIndexer) -> () in
            
            for elem in response["nodes"]["group"] {
                let scene = SceneRealm()
                
                //Get the name of the node
                if let name = elem["name"].element?.text!
                {
                    scene.name = name
                }
                //Get the current folder the node
                if let address = elem["address"].element?.text!
                {
                    scene.address = address
                }
                //Get the flag of the node
                if let deviceGroup = elem.element?.attributes["deviceGroup"]
                {
                    scene.deviceGroup = deviceGroup
                }
                //Get the address of the node
                if let parent = elem["parent"].element?.text!
                {
                    scene.parent = parent
                }
                for member in elem["members"]["link"]
                {
                    let memberAddress = member.element?.text!
                    let predicate = NSPredicate(format: "address = %@", memberAddress!)
                    let members = realm.objects(Node.self).filter(predicate)
                    scene.members.appendContentsOf(members)
                }
                
                //Check to see if the node is a dashboard item
                let predicate = NSPredicate(format: "address = %@", scene.address)
                let sceneRealmDashboard = realm.objects(SceneRealm.self).filter(predicate)
                if sceneRealmDashboard.count != 0
                {
                    scene.dashboardItem = sceneRealmDashboard[0].dashboardItem
                }
                
                //Save nodes to Realm
                try! realm.write({
                    realm.add(scene, update: true)
                })
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
        let folders = realm.objects(FolderRealm.self).filter(predicate)
        print("folder \(folders)")
        for folder in folders
        {
            displayArray.append(folder)
        }
        
        // Query all nodes using
        predicate = NSPredicate(format: "parent = %@", address)
        let scenes = realm.objects(SceneRealm.self).filter(predicate)
        print("scenes \(scenes)")
        for scene in scenes
        {
            displayArray.append(scene)
        }
        
        return displayArray
    }
    
    
    //Mark: node commands
    
    //runs the if portion of the program.
    func sceneCommand(scene: SceneRealm, command: String, completionHandler: (success: Bool) -> ())
    {
        ///rest/programs/0032/run|runThen|runElse|stop|enable|disable|enableRunAtStartup|disableRunAtStartup
        
        //Create url for on command
        var commandURLString = baseURLString + "nodes/" + scene.address + "/cmd/" + command
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
    
    
//    //add nodes to the proper folder array
//    func addScenes(completionHandler: (success: Bool) -> ())
//    {
//        self.createFolders { (success) in
//            if success
//            {
//                self.getScenes { (success) -> () in
//                    if success
//                    {
//                        //add scenes into sub folders
//                        for rootfolder in self.rootfolder.subfolderArray
//                        {
//                            for subfolder in rootfolder.subfolderArray
//                            {
//                                for scene in self.scenes
//                                {
//                                    if scene.parent == subfolder.address
//                                    {
//                                        subfolder.sceneArray += [scene]
//                                        subfolder.containsScene = true
//                                        rootfolder.containsScene = true
//                                        
//                                    }
//                                }
//                            }
//                        }
//                        
//                        //add scenes into root folder
//                        for rootfolder in self.rootfolder.subfolderArray
//                        {
//                            for scene in self.scenes
//                            {
//                                if scene.parent == rootfolder.address
//                                {
//                                    rootfolder.sceneArray += [scene]
//                                }
//                            }
//                        }
//                        
//                        
//                        //add nodes into root folder
//                        for scene in self.scenes
//                        {
//                            if scene.parent == ""
//                            {
//                                self.rootfolder.sceneArray += [scene]
//                            }
//                        }
//                        
//                        self.array = []
//                        for folder in self.rootfolder.subfolderArray
//                        {
//                            if folder.containsScene
//                            {
//                                self.array.append(folder)
//                            }
//                        }
//                        for scene in self.rootfolder.sceneArray
//                        {
//                            self.array.append(scene)
//                        }
//                    }
//                    completionHandler(success: true)
//                }
//            }
//        }
//    }
    
    
    
}
