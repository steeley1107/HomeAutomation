//
//  ViewController.swift
//  HomeAutomation
//
//  Created by Steele on 2015-12-29.
//  Copyright © 2015 Steele. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController, NSURLSessionDelegate {
    
    
    
    //Mark: Properties
    var elements = NSMutableDictionary()
    var element = NSString()
    var title1 = NSMutableString()
    var date = NSMutableString()
    var elementValue: String?
    var success = false
    var node = Node()

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        nameLabel.text = node.name
        addressLabel.text = node.address
        statusLabel.text = node.status
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func httpGet(request: NSMutableURLRequest!) {
        var configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
        
        var session = NSURLSession(configuration: configuration, delegate: self, delegateQueue:NSOperationQueue.mainQueue())
        
        var task = session.dataTaskWithRequest(request){
            (data: NSData?, response: NSURLResponse?, error: NSError?) -> Void in
            if error == nil {
                var result = NSString(data: data!, encoding:
                    NSASCIIStringEncoding)!
                NSLog("result %@", result)
                
                
            }
        }
        task.resume()
    }
    
    func URLSession(session: NSURLSession, didReceiveChallenge challenge: NSURLAuthenticationChallenge, completionHandler: (NSURLSessionAuthChallengeDisposition, NSURLCredential?) -> Void) {
        completionHandler(NSURLSessionAuthChallengeDisposition.UseCredential, NSURLCredential(forTrust: challenge.protectionSpace.serverTrust!))
    }
    
    
    
     
    
    
    
    @IBAction func onButton(sender: AnyObject) {
        
        //let onString = "/18%20F3%20D%201/cmd/DFON"
        //let onString = "/2B%2014%2084%201/cmd/DFON"
        //httpGet(NSMutableURLRequest(URL: NSURL(string: "https://admin:paintball1@69.165.175.141/rest/nodes/18%20F3%20D%201/cmd/DFON")!))
        httpGet(NSMutableURLRequest(URL: NSURL(string: "https://admin:paintball1@69.165.175.141/rest/nodes/2B%2014%2084%201/cmd/DFON")!))

        //refreshXML(onString)
        
        
    }
    
    
    @IBAction func offButton(sender: AnyObject) {
        
        //let offString = "/2B%2014%2084%201/cmd/DFOF"
        //httpGet(NSMutableURLRequest(URL: NSURL(string: "https://admin:paintball1@69.165.175.141/rest/nodes/18%20F3%20D%201/cmd/DFOF")!))
         httpGet(NSMutableURLRequest(URL: NSURL(string: "https://admin:paintball1@69.165.175.141/rest/nodes/2B%2014%2084%201/cmd/DFOF")!))
        
        
        //refreshXML(offString)
        
        
        
    }
    
    
}




