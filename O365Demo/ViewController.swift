//
//  ViewController.swift
//  O365Demo
//
//  Created by Kai Loh on 1/6/15.
//  Copyright (c) 2015 Kai. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    var resourceID : String = "https://clippy-my.sharepoint.com"
    var authorityURL : String = "https://login.windows.net/clippy.onmicrosoft.com"
    var clientID : String = "e58f1509-7cfd-4e55-bdfe-9aa6df0a47fa"
    var redirectURI : NSURL = NSURL(string: "https://www.google.com")!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var defaults: NSUserDefaults = NSUserDefaults.standardUserDefaults()
        
        var er : ADAuthenticationError? = nil
        var authContext:ADAuthenticationContext = ADAuthenticationContext(authority: authorityURL, error: &er)
        
        authContext.acquireTokenWithResource(resourceID, clientId: clientID, redirectUri: redirectURI) { (result: ADAuthenticationResult!) -> Void in
            if (result.accessToken == nil) {
                println("token nil")
            } else {
                defaults.setObject(result.accessToken, forKey: "accessTokenDefault")
                defaults.synchronize()
                println("accessToken: \(result.accessToken)")
            }
        }
        
        
        // Do any additional setup after loading the view, typically from a nib.
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}