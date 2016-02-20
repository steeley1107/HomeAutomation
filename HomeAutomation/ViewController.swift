//
//  ViewController.swift
//  HomeAutomation
//
//  Created by Steele on 2015-12-29.
//  Copyright © 2015 Steele. All rights reserved.
//

import UIKit

class ViewController: UIViewController, NSXMLParserDelegate, NSURLSessionDelegate {
    
    
    
    //Mark: Properties
    var parser = NSXMLParser()
    var posts = NSMutableArray()
    var elements = NSMutableDictionary()
    var element = NSString()
    var title1 = NSMutableString()
    var date = NSMutableString()
    var elementValue: String?
    var success = false
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        parser.delegate = self
        
        refreshXML("")
        httpGet(NSMutableURLRequest(URL: NSURL(string: "https://admin:paintball1@69.165.175.141/rest/nodes")!))
        
        
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
    
    //Mark: Delegate Functions
    
    func parser(parser: NSXMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]) {
        if elementName == "success" {
            elementValue = String()
        }
        
    }
    
    
    func parser(parser: NSXMLParser, foundCharacters string: String) {
        if elementValue != nil {
            elementValue! += string
            print("element value \(elementValue)")
        }
    }
    
    func parser(parser: NSXMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if elementName == "success" {
            if elementValue == "true" {
                success = true
            }
            elementValue = nil
        }
    }
    
    func parser(parser: NSXMLParser, parseErrorOccurred parseError: NSError) {
        print("parseErrorOccurred: \(parseError)")
    }
    
    
    //connection delegate functions
    
    
    //    func connection(connection: NSURLConnection, canAuthenticateAgainstProtectionSpace protectionSpace: NSURLProtectionSpace) -> Bool
    //    {
    //        return protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust
    //    }
    //
    //    func connection(connection: NSURLConnection, didReceiveAuthenticationChallenge challenge: NSURLAuthenticationChallenge)
    //    {
    //        if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust
    //        {
    //            if challenge.protectionSpace.host == "69.165.175.141"
    //            {
    //                let credentials = NSURLCredential(forTrust: challenge.protectionSpace.serverTrust!)
    //                challenge.sender!.useCredential(credentials, forAuthenticationChallenge: challenge)
    //            }
    //        }
    //
    //        challenge.sender!.continueWithoutCredentialForAuthenticationChallenge(challenge)
    //    }
    
    
    
    
    func URLSession(session: NSURLSession, didReceiveChallenge challenge: NSURLAuthenticationChallenge, completionHandler: (NSURLSessionAuthChallengeDisposition, NSURLCredential?) -> Void) {
        completionHandler(NSURLSessionAuthChallengeDisposition.UseCredential, NSURLCredential(forTrust: challenge.protectionSpace.serverTrust!))
    }
    
    
    
    func refreshXML(command: String) {
        
        let baseURL = "https://admin:paintball1@69.165.175.141/rest/nodes"
        
        var URLString = baseURL + command
        
        
        let urlCommand = NSURL(string: URLString)
        
        let queue:NSOperationQueue = NSOperationQueue()
        
        
        let task = NSURLSession.sharedSession().dataTaskWithURL(urlCommand!) { (data, response, error) -> Void in
            
            if(error != nil) {
                print(error)
            }
            
            print("response \(response)")
            print("data \(data)")
            
            //self.parser = NSXMLParser(data: data!)
            //self.parser.parse()
            
            print("")
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                
                let status = "OK" //dictionary!["status"] as! String
                
                //Cheak to see if google returned good data.
                if status == "OK" {
                    
                    
                    //completionHandler(sucess: true)
                }
                
                print("dict \(self.parser)")
            })
        }
        task.resume()
        
        
        
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




