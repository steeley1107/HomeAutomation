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
    static let sharedInstance = SceneManager()
    
    
    
    //Mark: Properties
    
    var displayArray = [Any]()
    var xml: XMLIndexer?
    var baseURLString = ""
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
    
    
    //grab data from xml and place scenes in a scene array
    func getScenes(completionHandler: (success: Bool) -> ())
    {
        let realm = try! Realm()
        
        let baseURL = NSURL(string: baseURLString + "nodes/scenes")
        requestData(NSMutableURLRequest(URL: baseURL!), completionHandler: { (response: XMLIndexer) -> () in
            
            for elem in response["nodes"]["group"] {
                let scene = Scene()
                
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
                let sceneRealmDashboard = realm.objects(Scene.self).filter(predicate)
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
        let folders = realm.objects(Folder.self).filter(predicate)
        for folder in folders
        {
            if folder.containsScene
            {
                displayArray.append(folder)
            }
        }
        
        // Query all nodes using
        predicate = NSPredicate(format: "parent = %@", address)
        let scenes = realm.objects(Scene.self).filter(predicate)
        for scene in scenes
        {
            displayArray.append(scene)
        }
        
        return displayArray
    }
    
    
    //Reurn the percentage of members that are on in the scene
    func sceneStatus(scene: Scene) -> String
    {
        var onCount = 0
        var percentOn = 0
        
        if scene.members.count > 1
        {
            for node in scene.members
            {
                if node.status == "ture" || node.status == "On"
                {
                    print("true ")
                    onCount += 1
                }
            }
            
            percentOn = onCount/scene.members.count * 100
            return percentOn.description + " %"
        }
        else
        {
            return scene.members[0].status
        }
    }
    
    
    //Mark: node commands
    
    //runs the if portion of the program.
    func sceneCommand(scene: Scene, command: String, completionHandler: (success: Bool) -> ())
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
                    self.nodeManager.getStatusAllNodes({ (success) in
                        if success
                        {
                            completionHandler(success: true)
                        }
                    })
                    
                }
            }
        })
    }
    
    
    //Need to add perameters to allow for queries of different types
    func queryNodesFromRealm() -> [Any]
    {
        let realm = try! Realm()
        
        // Query using an NSPredicate
        let predicate = NSPredicate(format: "dashboardItem = %@", true)
        let elements = realm.objects(Scene.self).filter(predicate)
        
        var scenes = [Any]()
        for elem in elements
        {
            scenes.append(elem)
        }
        return scenes
    }
    
    
    
}
