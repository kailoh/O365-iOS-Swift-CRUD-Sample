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
    var client: MSSharePointClient? = nil
    
    override func viewDidLoad() {
        self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        var resolver : MSODataDefaultDependencyResolver = MSODataDefaultDependencyResolver()

        var credentials : MSODataOAuthCredentials = MSODataOAuthCredentials()
        var defaults: NSUserDefaults = NSUserDefaults.standardUserDefaults()
        
        credentials.addToken(defaults.objectForKey("accessTokenDefault") as String)
        
        var credentialsImpl : MSODataCredentialsImpl = MSODataCredentialsImpl()
        
        credentialsImpl.setCredentials(credentials)
        
        resolver.setCredentialsFactory(credentialsImpl)
        
        client = MSSharePointClient(url: "https://clippy-my.sharepoint.com/_api/v1.0/me", dependencyResolver: resolver)
        
        self.getFiles()
        self.tableView.allowsMultipleSelection = false
        
        super.viewDidLoad()
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.files.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell : UITableViewCell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath:indexPath) as UITableViewCell
        var file: MSSharePointItem = self.files[indexPath.row]
        cell.textLabel?.text = file.name
        println(file.dateTimeCreated)
        println(file.dateTimeLastModified)
        println(file.size)
        println(file.createdBy)
        println(file.lastModifiedBy)
        println(file.parentReference)
        println(file.webUrl)
        return cell
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if (editingStyle == UITableViewCellEditingStyle.Delete) {
            var fileToDelete: MSSharePointItem = self.files[indexPath.row] as MSSharePointItem
            self.client?.getfiles().getById(fileToDelete.id).addCustomHeaderWithName("If-Match", andValue: "*").deleteItem!({ (status: Int32, exception: MSODataException?) -> Void in
                if (exception == nil) {
                    dispatch_async(dispatch_get_main_queue(), {
                        self.getFiles()
                    })
                } else {
                    println("EXCEPTION: \(exception)")
                }
            }).resume()
        } //https://github.com/OfficeDev/Office-365-SDK-for-Android/issues/38
    }
    
    func getFiles() {
        client!.getfiles().read{(someObjects:[AnyObject]!, exception:MSODataException?) -> Void in
            if (exception == nil) {
                dispatch_async(dispatch_get_main_queue(), {
                    self.files = someObjects as [MSSharePointItem]
                    self.tableView.reloadData()
                })
            } else {
                println("Error: \(exception)")
            }
        }.resume()
    }
    
    @IBAction func updateLastFile(sender: AnyObject) {
        let content = "This is my new file content"
        let encodedContent = content.dataUsingEncoding(NSUTF8StringEncoding)
        self.client?.getfiles().getById(files[files.count-1].id).asFile().putContent(encodedContent, withCallback: { (result: Int, exception:MSODataException?) -> Void in
            if (exception == nil) {
                println("Result: \(result)")
                self.getFiles()
            } else {
                println("Exception: \(exception)")
            }
        }).resume()

    }
    
    @IBAction func addFile(sender: AnyObject) {
        var newItem : MSSharePointItem = MSSharePointItem()
        newItem.name = "MyNewFileName"
        newItem.type = "File"
        let content = "This is my new file content"
        let encodedContent = content.dataUsingEncoding(NSUTF8StringEncoding)
        
        self.client?.getfiles().addItem(newItem, withCallback: { (item:MSSharePointItem?, exception:MSODataException?) -> Void in
            if (exception == nil) {
                self.client?.getfiles().getById(item!.id).asFile().putContent(encodedContent, withCallback: { (result: Int, exception:MSODataException?) -> Void in
                    if (exception == nil) {
                        println("Result: \(result)")
                        self.getFiles()
                    } else {
                        println("Exception: \(exception)")
                    }
                }).resume()
                
            } else {
                println("Exception: \(exception)")
            }
        }).resume()
        
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        var myCell: UITableViewCell = tableView.cellForRowAtIndexPath(indexPath)!
        let id = self.files[indexPath.row].id
        
        self.client?.getfiles().getById(id).asFile().getContentWithCallback({ (data: NSData?, exception: MSODataException?) -> Void in
            if (exception == nil) {
                let fileContent = NSString(data: data!, encoding: NSUTF8StringEncoding)
                println("Data: \(data)")
                println("FileContent: \(fileContent)")
            } else {
                println("Exception: \(exception)")
            }
        }).resume()
    }
    
    
}