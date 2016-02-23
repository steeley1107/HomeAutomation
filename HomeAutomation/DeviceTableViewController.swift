//
//  DeviceTableViewController.swift
//  HomeAutomation
//
//  Created by Steele on 2016-02-19.
//  Copyright © 2016 Steele. All rights reserved.
//

import UIKit

class DeviceTableViewController: UITableViewController, NSXMLParserDelegate, NSURLSessionDelegate {
    
    //Mark: Properties
    var parser = NSXMLParser()
    var posts = NSMutableArray()
    var elements = NSMutableDictionary()
    var element = NSString()
    var title1 = NSMutableString()
    var date = NSMutableString()
    var elementValue: String?
    var success = false
    var node = Node()
    var nodes = [Node]()
    var folders = NSMutableDictionary()
    var folderName = NSMutableString()

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //3parser.delegate = self
        //beginParsing()
        
        httpGet(NSMutableURLRequest(URL: NSURL(string: "https://admin:paintball1@69.165.175.141/rest/nodes")!))
        
        
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return nodes.count
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        var cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
        
        // Configure the cell...
        
        cell.textLabel?.text = nodes[indexPath.row].name
        cell.detailTextLabel?.text = nodes[indexPath.row].status
        
        
        return cell
    }
    
    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
    // Return false if you do not want the specified item to be editable.
    return true
    }
    */
    
    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
    if editingStyle == .Delete {
    // Delete the row from the data source
    tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
    } else if editingStyle == .Insert {
    // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }
    }
    */
    
    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {
    
    }
    */
    
    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
    // Return false if you do not want the item to be re-orderable.
    return true
    }
    */
    
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
    {
        if (segue.identifier == "Details") {
            let detailVC:DetailViewController = segue.destinationViewController as! DetailViewController
            // let selectedIndex = self.tableView.indexPathForCell(sender as! UITableViewCell)
            let indexPath = tableView.indexPathForSelectedRow
            let selectedNode = nodes[indexPath!.row] as Node
            detailVC.node = selectedNode
            
        }
    }
    
    
    
    // get information from ISY994
    func httpGet(request: NSMutableURLRequest!)
    {
        var configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
        
        var session = NSURLSession(configuration: configuration, delegate: self, delegateQueue:NSOperationQueue.mainQueue())
        
        var task = session.dataTaskWithRequest(request){
            (data: NSData?, response: NSURLResponse?, error: NSError?) -> Void in
            if error == nil {
                var result = NSString(data: data!, encoding:
                    NSASCIIStringEncoding)!
                NSLog("result %@", result)
                self.posts = []
                self.parser = NSXMLParser(data: data!)
                self.parser.delegate = self
                self.parser.parse()
                self.tableView!.reloadData()
            }
        }
        task.resume()
    }
    
    
    func URLSession(session: NSURLSession, didReceiveChallenge challenge: NSURLAuthenticationChallenge, completionHandler: (NSURLSessionAuthChallengeDisposition, NSURLCredential?) -> Void)
    {
        completionHandler(NSURLSessionAuthChallengeDisposition.UseCredential, NSURLCredential(forTrust: challenge.protectionSpace.serverTrust!))
    }
    
    
    
    //Mark: Parser Delegate Functions
    
    func parser(parser: NSXMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String])
    {
        if elementName == "success"
        {
            elementValue = String()
        }
        
        if elementName == "property"
        {
            //print("111111 \(attributeDict["formatted"])")
            node.status = attributeDict["formatted"]!
            
        }
        
        
        element = elementName
        if (elementName as NSString).isEqualToString("node")
        {
            elements = NSMutableDictionary()
            elements = [:]
            title1 = NSMutableString()
            title1 = ""
            date = NSMutableString()
            date = ""
            
            node = Node()
        }
        
        //find folders
        if (elementName as NSString).isEqualToString("folder")
        {
            
            folders = NSMutableDictionary()
            folders = [:]
            //            elements = [:]
            //            title1 = NSMutableString()
            //            title1 = ""
            //            date = NSMutableString()
            //            date = ""
        }
        
        
        
        
        
        
    }
    
    func parser(parser: NSXMLParser, foundCharacters string: String) {
        if elementValue != nil {
            elementValue! += string
            print("element value \(elementValue)")
        }
        
        if element.isEqualToString("name")
        {
            //title1.appendString(string)
            node.name = string
        }
        else if element.isEqualToString("address")
        {
            //print("property \(element)")
            //date.appendString(string)
            node.address = string
        }
        else if element.isEqualToString("type")
        {
            node.type = string
        }
        else if element.isEqualToString("enabled")
        {
            node.enabled = string
        }
        else if element.isEqualToString("deviceClass")
        {
            node.deviceClass = string
        }
        else if element.isEqualToString("wattage")
        {
            node.wattage = string
        }
        else if element.isEqualToString("property")
        {
            print("property xxx \(element)")
            
        }
        
        
        //if element.isEqualToString("name")
        
        
        
        
    }
    
    func parser(parser: NSXMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if elementName == "success" {
            if elementValue == "true" {
                success = true
            }
            elementValue = nil
        }
        
        
        
        //        if (elementName as NSString).isEqualToString("node")
        //        {
        //            if !title1.isEqual(nil) {
        //                elements.setObject(title1, forKey: "name")
        //            }
        //            if !date.isEqual(nil) {
        //                elements.setObject(date, forKey: "property")
        //            }
        //            posts.addObject(elements)
        //
        //        }
        
        
        if (elementName as NSString).isEqualToString("node")
        {
            nodes.append(node)
        }
        
        
        if (elementName as NSString).isEqualToString("folder")
        {
            if !folderName.isEqual(nil) {
                folders.setObject(folderName, forKey: "name")
            }
//            if !date.isEqual(nil) {
//                folders.setObject(date, forKey: "property")
//            }
//            //folders.addObject(elements)
            
            
        }
        
        
        
        
        
        
        
        
    }
    
    func parser(parser: NSXMLParser, parseErrorOccurred parseError: NSError)
    {
        print("parseErrorOccurred: \(parseError)")
    }
    
    
    
}
