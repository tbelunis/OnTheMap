//
//  StudentLocationTableViewController.swift
//  OnTheMap
//
//  Created by TOM BELUNIS on 5/13/15.
//  Copyright (c) 2015 TOM BELUNIS. All rights reserved.
//

import UIKit

class StudentLocationTableViewController: UIViewController {

    var studentLocations = OTMStudentLocations.sharedInstance()
    
    @IBOutlet var studentLocationsTableView: UITableView!
    @IBOutlet weak var addLocationButton: UIBarButtonItem!
    @IBOutlet weak var refreshListButton: UIBarButtonItem!
    @IBOutlet weak var toolBar: UIToolbar!
    @IBOutlet weak var logoffButton: UIBarButtonItem!
    @IBOutlet weak var spacer: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.studentLocationsTableView.delegate = self
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.navigationItem.setRightBarButtonItems([refreshListButton, addLocationButton], animated: true)
        self.tabBarController?.navigationItem.setLeftBarButtonItem(logoffButton, animated: true)
        self.toolBar.hidden = true
        loadLocationsTable()
    }
    
    func loadLocationsTable() {
        // Use the client to get the student locations
        OTMClient.sharedInstance().getStudentLocations { locations, error in
            if let locations = locations {
                self.studentLocations = locations
                dispatch_async(dispatch_get_main_queue(), {
                    self.studentLocationsTableView.reloadData()
                })
            } else {
                let alertController = UIAlertController.alertWithError("Error getting student locations", error: error!)
                self.presentViewController(alertController, animated: true, completion: nil)
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // Add location pin touched so present the information posting view
    @IBAction func addLocationButtonTouch(sender: UIBarButtonItem) {
        let controller = self.storyboard!.instantiateViewControllerWithIdentifier("InformationPostingView") as! UIViewController
        self.presentViewController(controller, animated: true, completion: nil)
    }
 
    // Refresh the map with udpated student locations
    @IBAction func refreshListButtonTouch(sender: UIBarButtonItem) {
        loadLocationsTable()
    }

    // Log off from Udacity
    @IBAction func logoffButtonTouch(sender: UIBarButtonItem) {
        OTMClient.sharedInstance().logoffOfUdacity() { result, error in
            if let error = error {
                UIAlertController.alertWithError("Error Logging Off", error: error)
            } else {
                // User has logged off, dismiss view
                self.dismissViewControllerAnimated(true, completion: nil)
            }
        }
    }

}

// MARK: Implement the UITableViewDataSource methods
extension StudentLocationTableViewController: UITableViewDataSource {
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return studentLocations.count
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("ListCell", forIndexPath: indexPath) as! UITableViewCell
        
        cell.textLabel?.text = studentLocations[indexPath.row].fullName
        cell.detailTextLabel?.text = studentLocations[indexPath.row].mediaURL
        
        return cell
    }
}

// MARK: Implement the UITableViewDelegate methods
extension StudentLocationTableViewController: UITableViewDelegate {
    
    // When a row is selected, try to open the URL in Safari
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let mediaUrl = studentLocations[indexPath.row].mediaURL
        // Validate the URL before trying to open it in Safari
        OTMClient.sharedInstance().validateURL(mediaUrl) { result, error in
            // Alert the user if the URL was not valid
            if let error = error {
                let alertController = UIAlertController.alertWithError("Invalid URL", error: error)
                self.presentViewController(alertController, animated: true, completion: nil)
            } else {
                // URL was valid, open the URL in Safari
                dispatch_async(dispatch_get_main_queue(), {
                    OTMClient.sharedInstance().openURLInSafari(NSURL(string: mediaUrl)!)
                })
            }
        }
    }
}
