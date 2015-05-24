//
//  StudentLocationTableViewController.swift
//  OnTheMap
//
//  Created by TOM BELUNIS on 5/13/15.
//  Copyright (c) 2015 TOM BELUNIS. All rights reserved.
//

import UIKit

class StudentLocationTableViewController: UIViewController {

    var studentLocations: [OTMStudentLocation] = [OTMStudentLocation]()
    
    @IBOutlet var studentLocationsTableView: UITableView!
    @IBOutlet weak var addLocationButton: UIBarButtonItem!
    @IBOutlet weak var refreshListButton: UIBarButtonItem!
    @IBOutlet weak var toolBar: UIToolbar!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        self.tabBarController?.navigationItem.setRightBarButtonItems([refreshListButton, addLocationButton], animated: true)
        self.toolBar.hidden = true
    }
    
    override func viewWillAppear(animated: Bool) {
        loadLocationsTable()
    }
    
    func loadLocationsTable() {
        OTMClient.sharedInstance().getStudentLocations { locations, error in
            if let locations = locations {
                self.studentLocations = locations
                dispatch_async(dispatch_get_main_queue(), {
                    self.studentLocationsTableView.reloadData()
                })
            } else {
                println(error)
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func addLocationButtonTouch(sender: UIBarButtonItem) {
        
    }
    
    @IBAction func refreshListButtonTouch(sender: UIBarButtonItem) {
        loadLocationsTable()
    }

}

extension StudentLocationTableViewController: UITableViewDataSource {
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return studentLocations.count
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("ListCell", forIndexPath: indexPath) as! UITableViewCell
        
        cell.textLabel?.text = studentLocations[indexPath.row].fullName
        
        return cell
    }
}

extension StudentLocationTableViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        let mediaUrl = studentLocations[indexPath.row].mediaURL
        OTMClient.sharedInstance().validateURL(mediaUrl) { result, error in
            if let error = error {
                println("Invalid URL")
            } else {
                OTMClient.sharedInstance().openURLInSafari(NSURL(string: mediaUrl)!)
            }
        }
    }
}
