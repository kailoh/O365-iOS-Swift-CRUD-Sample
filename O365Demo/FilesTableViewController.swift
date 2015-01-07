//
//  FilesTableViewController.swift
//  O365Demo
//
//  Created by Kai Loh on 1/6/15.
//  Copyright (c) 2015 Kai. All rights reserved.
//

import UIKit

class FilesTableViewController: UITableViewController {
    
    var files: [MSSharePointItem] = []
    
    override func viewDidLoad() {
        self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        var resolver : MSODataDefaultDependencyResolver = MSODataDefaultDependencyResolver()
        
        var credentials : MSODataOAuthCredentials = MSODataOAuthCredentials()
        var defaults: NSUserDefaults = NSUserDefaults.standardUserDefaults()
        
        credentials.addToken(defaults.objectForKey("accessTokenDefault123") as String)
        
        var credentialsImpl : MSODataCredentialsImpl = MSODataCredentialsImpl()
        
        credentialsImpl.setCredentials(credentials)
        
        resolver.setCredentialsFactory(credentialsImpl)
        
        var client : MSSharePointClient = MSSharePointClient(url: "https://clippy-my.sharepoint.com/_api/v1.0/me", dependencyResolver: resolver)
        
        var task : NSURLSessionTask = client.getfiles().read{(someObjects:[AnyObject]!, error:MSODataException!) -> Void in
            if (error == nil) {
                dispatch_async(dispatch_get_main_queue(), {
                    self.files = someObjects as [MSSharePointItem]
                    self.tableView.reloadData()
                })
            } else {
                println("Error: \(error)")
            }
        }
        
        task.resume()
        
        super.viewDidLoad()
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.files.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell : UITableViewCell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath:indexPath) as UITableViewCell
        var file: MSSharePointItem = self.files[indexPath.row]
        cell.textLabel?.text = file.name
        return cell
    }
    
}